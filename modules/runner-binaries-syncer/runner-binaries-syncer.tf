data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_s3_object" "lambda_s3_bucket" {
  bucket = local.lambda_bucket
  key    = "runner-binaries-syncer.zip"
}

locals {
  gh_binary_os_label = "linux"
  lambda_bucket      = "${var.stack_name}-${var.prefix}-${terraform.workspace}-bucket"
  cidr_block         = var.cidr_block[terraform.workspace]
  tags = {
    Name        = "${var.stack_name}-${var.prefix}-lambda"
    Environment = terraform.workspace
  }
}

resource "aws_lambda_function" "syncer" {
  s3_bucket         = data.aws_s3_object.lambda_s3_bucket.bucket
  s3_key            = data.aws_s3_object.lambda_s3_bucket.key
  s3_object_version = data.aws_s3_object.lambda_s3_bucket.version_id
  # filename          = data.aws_s3_object.lambda_s3_bucket.key
  source_code_hash = filebase64sha256("../modules/download-upload-lambda/runner-binaries-syncer.zip")
  function_name    = "${var.stack_name}-${var.prefix}-runner-binaries-syncer"
  role             = aws_iam_role.syncer_lambda.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = 512
  architectures    = [var.lambda_architecture]

  environment {
    variables = {
      GITHUB_RUNNER_ARCHITECTURE = var.runner_architecture
      GITHUB_RUNNER_OS           = local.gh_binary_os_label
      LOG_LEVEL                  = var.log_level
      LOG_TYPE                   = var.log_type
      S3_BUCKET_NAME             = aws_s3_bucket.action_dist.bucket
      S3_OBJECT_KEY              = local.action_runner_distribution_object_key
    }
  }

  # vpc_config {
  #   security_group_ids = [aws_security_group.runner_bin_sg.id]
  #   subnet_ids         = [var.lambda_subnet_ids[*]]
  # }

  dynamic "vpc_config" {
    for_each = var.lambda_subnet_ids != null ? [true] : []
    content {
      security_group_ids = [aws_security_group.runner_bin_sg.id]
      subnet_ids         = var.lambda_subnet_ids
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "syncer" {
  name              = "/aws/lambda/${aws_lambda_function.syncer.function_name}"
  retention_in_days = var.logging_retention_in_days
  # kms_key_id        = var.logging_kms_key_id
  tags = local.tags
}

resource "aws_iam_role" "syncer_lambda" {
  name               = "${var.stack_name}-action-syncer-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = local.tags
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.stack_name}-${var.prefix}-lambda-logging-policy-syncer"
  role = aws_iam_role.syncer_lambda.id

  policy = templatefile("${path.module}/policies/lambda-cloudwatch.json", {
    log_group_arn = "${aws_cloudwatch_log_group.syncer.arn}",
    other_arn     = "*"
  })
}

resource "aws_iam_role_policy" "lambda_syncer_vpc" {
  count = length(var.lambda_subnet_ids) > 0 && length([aws_security_group.runner_bin_sg.id]) > 0 ? 1 : 0
  name  = "${var.stack_name}-${var.prefix}-lambda-syncer-vpc"
  role  = aws_iam_role.syncer_lambda.id

  policy = file("${path.module}/policies/lambda-vpc.json")
}

resource "aws_iam_role_policy" "syncer" {
  name = "${var.stack_name}-${var.prefix}-lambda-syncer-s3-policy"
  role = aws_iam_role.syncer_lambda.id

  policy = templatefile("${path.module}/policies/lambda-syncer.json", {
    s3_resource_arn_3 = "${aws_s3_bucket.action_dist.arn}/${local.action_runner_distribution_object_key}",
    s3_resource_arn_1 = "${aws_s3_bucket.action_dist.arn}",
    s3_resource_arn_2 = "${aws_s3_bucket.action_dist.arn}/*",
    other_arn         = "*"
  })
}

resource "aws_iam_role_policy" "ec2" {
  name = "${var.stack_name}-${var.prefix}-lambda-syncer-ec2-policy"
  role = aws_iam_role.syncer_lambda.id

  policy = templatefile("${path.module}/policies/lambda-ec2.json", {
    all_arn = "*"
  })
}

resource "aws_cloudwatch_event_rule" "syncer" {
  name                = "${var.stack_name}-${var.prefix}-syncer-rule"
  schedule_expression = var.lambda_schedule_expression
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "syncer" {
  rule = aws_cloudwatch_event_rule.syncer.name
  arn  = aws_lambda_function.syncer.arn
}

resource "aws_lambda_permission" "syncer" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.syncer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.syncer.arn
}

# data "aws_iam_policy_document" "access_to_dist_bucket" {
#   statement {
#     principals {
#       type = "AWS"
#       identifiers = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.stack_name}-action-syncer-lambda-role",
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.stack_name}-${var.prefix}-runner-role"
#       ]
#     }
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:PutObjectAcl",
#       "s3:AbortMultipartUpload",
#       "s3:GetBucketLocation",
#       "s3:ListBucket",
#       "s3:ListBucketMultipartUploads"
#     ]
#     resources = [
#       "${aws_s3_bucket.action_dist.arn}",
#       "${aws_s3_bucket.action_dist.arn}/*"
#     ]
#   }
# }


# resource "aws_s3_bucket_policy" "access_to_dist_bucket" {
#   bucket = aws_s3_bucket.action_dist.id
#   policy = data.aws_iam_policy_document.access_to_dist_bucket.json
# }

###################################################################################
### Extra trigger to trigger from S3 to execute the lambda after first deployment
###################################################################################

resource "aws_s3_object" "trigger" {
  bucket     = aws_s3_bucket.action_dist.id
  key        = "triggers/${aws_lambda_function.syncer.id}-trigger.json"
  source     = "${path.module}/trigger.json"
  depends_on = [aws_s3_bucket_notification.on_deploy]
}

resource "aws_s3_bucket_notification" "on_deploy" {
  bucket = aws_s3_bucket.action_dist.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.syncer.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "triggers/"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.on_deploy]
}

resource "aws_lambda_permission" "on_deploy" {
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.syncer.arn
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = aws_s3_bucket.action_dist.arn
}

resource "aws_security_group" "runner_bin_sg" {
  name        = "${var.stack_name}-${var.prefix}-runner-bin-sg"
  description = "Github Actions Runner Binaries Syncer security group"

  vpc_id = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${local.cidr_block}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}