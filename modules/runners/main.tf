data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_s3_object" "lambda_s3_bucket" {
  bucket = local.lambda_bucket
  key    = "runners.zip"
}

locals {
  lambda_bucket         = "${var.stack_name}-${var.prefix}-${terraform.workspace}-bucket"
  cidr_block            = var.cidr_block[terraform.workspace]
  default_runner_labels = "self-hosted,${var.runner_os},${var.runner_architecture}"
  runner_labels         = var.runner_extra_labels != "" ? "${local.default_runner_labels},${var.runner_extra_labels}" : local.default_runner_labels
  tags = {
    Name        = "${var.stack_name}-${var.prefix}-lambdas"
    Environment = terraform.workspace
  }

  name_sg                         = "${var.stack_name}-${var.prefix}-sg"
  name_runner                     = "${var.stack_name}-${var.prefix}-runner"
  instance_profile_path           = var.instance_profile_path == null ? "/${var.stack_name}-${var.prefix}/" : var.instance_profile_path
  lambda_zip                      = data.aws_s3_object.lambda_s3_bucket.key
  userdata_template               = var.userdata_template == null ? local.default_userdata_template : var.userdata_template
  s3_location_runner_distribution = var.enable_runner_binaries_syncer ? "s3://${var.s3_runner_binaries.id}/${var.s3_runner_binaries.key}" : ""
  default_ami                     = var.runner_architecture == "arm64" ? { name = ["amzn2-ami-kernel-5.*-hvm-*-arm64-gp2"] } : { name = ["amzn2-ami-kernel-5.*-hvm-*-x86_64-gp2"] }
  default_userdata_template       = "${path.module}/templates/user-data.sh"
  userdata_install_runner         = "${path.module}/templates/install-runner.sh"
  userdata_start_runner           = "${path.module}/templates/start-runner.sh"
  ami_filter                      = coalesce(var.ami_filter, local.default_ami)
  enable_job_queued_check         = var.enable_job_queued_check == null ? !var.enable_ephemeral_runners : var.enable_job_queued_check
}

data "aws_ami" "runner" {
  most_recent = "true"

  dynamic "filter" {
    for_each = local.ami_filter
    content {
      name   = filter.key
      values = filter.value
    }
  }

  # owners = ["${data.aws_caller_identity.current.account_id}"]
  owners = var.ami_owners
}

resource "tls_private_key" "algorithm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.stack_name}-${var.prefix}-key"
  public_key = tls_private_key.algorithm.public_key_openssh
}

resource "aws_launch_template" "runner" {
  name = "${var.stack_name}-${var.prefix}-runner-launch-template"

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings != null ? var.block_device_mappings : []
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        delete_on_termination = block_device_mappings.value.delete_on_termination
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
      }
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []

    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_tokens                 = metadata_options.value.http_tokens
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      instance_metadata_tags      = "enabled"
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [] : [0]

    content {
      instance_metadata_tags = "enabled"
    }
  }

  monitoring {
    enabled = var.enable_runner_detailed_monitoring
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.runner.name
  }

  instance_initiated_shutdown_behavior = "terminate"
  image_id                             = data.aws_ami.runner.id
  key_name                             = aws_key_pair.generated_key.key_name

  vpc_security_group_ids = compact(concat(
    var.enable_managed_runner_security_group ? [aws_security_group.runner_sg[0].id] : [],
    var.runner_additional_security_group_ids,
  ))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.stack_name}-${var.prefix}-instance"
      Environment = terraform.workspace
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "${var.stack_name}-${var.prefix}-volume"
      Environment = terraform.workspace
    }
  }

  user_data = var.enabled_userdata ? base64encode(templatefile(local.userdata_template, {
    enable_debug_logging            = var.enable_user_data_debug_logging
    s3_location_runner_distribution = local.s3_location_runner_distribution
    pre_install                     = var.userdata_pre_install
    install_runner = templatefile(local.userdata_install_runner, {
      S3_LOCATION_RUNNER_DISTRIBUTION = local.s3_location_runner_distribution
      RUNNER_ARCHITECTURE             = var.runner_architecture
    })
    post_install = var.userdata_post_install
    start_runner = templatefile(local.userdata_start_runner, {})

    ## retain these for backwards compatibility
    environment                     = terraform.workspace
    enable_cloudwatch_agent         = var.enable_cloudwatch_agent
    ssm_key_cloudwatch_agent_config = var.enable_cloudwatch_agent ? aws_ssm_parameter.cloudwatch_agent_config_runner[0].name : ""
  })) : ""

  tags = local.tags

  update_default_version = true
}

resource "aws_security_group" "runner_sg" {
  count       = var.enable_managed_runner_security_group ? 1 : 0
  name        = "${var.stack_name}-${var.prefix}-runner-sg"
  description = "Github Actions Runner security group"

  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.egress_rules
    iterator = each

    content {
      cidr_blocks      = each.value.cidr_blocks
      ipv6_cidr_blocks = each.value.ipv6_cidr_blocks
      from_port        = each.value.from_port
      protocol         = each.value.protocol
      to_port          = each.value.to_port
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = each

    content {
      cidr_blocks = each.value.cidr_blocks
      from_port   = each.value.from_port
      protocol    = each.value.protocol
      to_port     = each.value.to_port
      description = each.value.description
    }
  }

}


output "launch_template" {
  value = aws_launch_template.runner
}

output "role_runner" {
  value = aws_iam_role.runner
}

output "lambda_scale_up" {
  value = aws_lambda_function.scale_up
}

output "role_scale_up" {
  value = aws_iam_role.scale_up
}

output "lambda_scale_down" {
  value = aws_lambda_function.scale_down
}

output "role_scale_down" {
  value = aws_iam_role.scale_down
}

output "role_pool" {
  value = length(var.pool_config) == 0 ? null : module.pool[0].role_pool
}