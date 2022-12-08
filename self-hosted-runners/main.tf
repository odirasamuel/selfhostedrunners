module "get_lambdas" {
  count  = (terraform.workspace == "dev") ? 1 : 0
  source = "../modules/download-upload-lambda"

  stack_name = var.stack_name
  prefix     = var.prefix

  providers = {
    aws = aws.dev
  }
}

module "ssm" {
  count  = (terraform.workspace == "dev") ? 1 : 0
  source = "../modules/ssm"

  prefix     = var.prefix
  stack_name = var.stack_name
  github_app = var.github_app

  providers = {
    aws = aws.dev
  }
}

module "sqs" {
  count  = (terraform.workspace == "dev") ? 1 : 0
  source = "../modules/sqs"

  prefix                           = var.prefix
  stack_name                       = var.stack_name
  enable_workflow_job_events_queue = var.enable_workflow_job_events_queue
  delay_webhook_event              = var.delay_webhook_event
  runners_scale_up_lambda_timeout  = var.runners_scale_up_lambda_timeout
  job_queue_retention_in_seconds   = var.job_queue_retention_in_seconds
  fifo_build_queue                 = var.fifo_build_queue
  redrive_build_queue              = var.redrive_build_queue
  queue_encryption                 = var.queue_encryption
  workflow_job_queue_configuration = var.workflow_job_queue_configuration

  providers = {
    aws = aws.dev
  }
}

module "test_dev_vpc" {
  count  = (terraform.workspace == "dev") ? 1 : 0
  source = "../modules/vpc"

  availability_zones    = var.availability_zones
  cidr_block            = var.cidr_block
  public_subnets_count  = var.public_subnets_count
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_count = var.private_subnets_count
  private_subnets_cidr  = var.private_subnets_cidr
  nat_gateway_count     = var.nat_gateway_count
  elastic_ips           = var.elastic_ips
  stack_name            = var.stack_name

  providers = {
    aws = aws.dev
  }
}

module "runner_binaries_syncer" {
  count  = (terraform.workspace == "dev") ? 1 : 0
  source = "../modules/runner-binaries-syncer"

  distribution_bucket_name   = var.distribution_bucket_name
  lambda_timeout             = var.lambda_timeout
  runner_os                  = var.runner_os
  lambda_runtime             = var.lambda_runtime
  lambda_architecture        = var.lambda_architecture
  runner_architecture        = var.runner_architecture
  log_level                  = var.log_level
  log_type                   = var.log_type
  lambda_subnet_ids          = ["${module.test_dev_vpc[0].private_subnets_1_id}", "${module.test_dev_vpc[0].private_subnets_2_id}", "${module.test_dev_vpc[0].private_subnets_3_id}"]
  logging_retention_in_days  = var.logging_retention_in_days
  lambda_schedule_expression = var.lambda_schedule_expression
  stack_name                 = var.stack_name
  prefix                     = var.prefix
  vpc_id                     = module.test_dev_vpc[0].vpc_id
  cidr_block                 = var.cidr_block

  providers = {
    aws = aws.dev
  }

  depends_on = [
    module.get_lambdas,
    module.test_dev_vpc
  ]
}

module "runners" {
  count  = (terraform.workspace == "dev") ? 1 : 0
  source = "../modules/runners"

  stack_name                    = var.stack_name
  prefix                        = var.prefix
  instance_profile_path         = var.instance_profile_path
  userdata_template             = var.userdata_template
  runner_os                     = var.runner_os
  runner_architecture           = var.runner_architecture
  enable_runner_binaries_syncer = var.enable_runner_binaries_syncer
  s3_runner_binaries = {
    arn = module.runner_binaries_syncer[0].dist_bucket_arn
    id  = module.runner_binaries_syncer[0].dist_bucket_id
    key = module.runner_binaries_syncer[0].runner_distribution_object_key
  }
  ami_filter                                 = var.ami_filter
  enable_job_queued_check                    = var.enable_job_queued_check
  enable_ephemeral_runners                   = var.enable_ephemeral_runners
  ami_owners                                 = var.ami_owners
  block_device_mappings                      = var.block_device_mappings
  metadata_options                           = var.metadata_options
  enable_runner_detailed_monitoring          = var.enable_runner_detailed_monitoring
  enable_managed_runner_security_group       = var.enable_managed_runner_security_group
  runner_additional_security_group_ids       = var.runner_additional_security_group_ids
  enabled_userdata                           = var.enabled_userdata
  enable_user_data_debug_logging             = var.enable_user_data_debug_logging
  userdata_pre_install                       = var.userdata_pre_install
  userdata_post_install                      = var.userdata_post_install
  enable_cloudwatch_agent                    = var.enable_cloudwatch_agent
  vpc_id                                     = module.test_dev_vpc[0].vpc_id
  egress_rules                               = var.egress_rules
  ingress_rules                              = var.ingress_rules
  enable_ssm_on_runners                      = var.enable_ssm_on_runners
  runner_iam_role_managed_policy_arns        = var.runner_iam_role_managed_policy_arns
  instance_allocation_strategy               = var.instance_allocation_strategy
  instance_max_spot_price                    = var.instance_max_spot_price
  instance_target_capacity_type              = var.instance_target_capacity_type
  instance_types                             = var.instance_types
  log_level                                  = var.log_level
  log_type                                   = var.log_type
  logging_retention_in_days                  = var.logging_retention_in_days
  # pool_lambda_reserved_concurrent_executions = var.pool_lambda_reserved_concurrent_executions
  lambda_subnet_ids                          = ["${module.test_dev_vpc[0].private_subnets_1_id}", "${module.test_dev_vpc[0].private_subnets_2_id}", "${module.test_dev_vpc[0].private_subnets_3_id}"]
  lambda_architecture                        = var.lambda_architecture
  lambda_runtime                             = var.lambda_runtime
  pool_lambda_timeout                        = var.pool_lambda_timeout
  disable_runner_autoupdate                  = var.disable_runner_autoupdate
  runner_group_name                          = var.runner_group_name
  pool_runner_owner                          = var.pool_runner_owner
  subnet_ids                                 = ["${module.test_dev_vpc[0].private_subnets_1_id}", "${module.test_dev_vpc[0].private_subnets_2_id}", "${module.test_dev_vpc[0].private_subnets_3_id}"]
  aws_partition                              = var.aws_partition
  runner_as_root                             = var.runner_as_root
  runner_run_as                              = var.runner_run_as
  lambda_timeout_scale_down                  = var.lambda_timeout_scale_down
  minimum_running_time_in_minutes            = var.minimum_running_time_in_minutes
  runner_boot_time_in_minutes                = var.runner_boot_time_in_minutes
  idle_config                                = var.idle_config
  scale_down_schedule_expression             = var.scale_down_schedule_expression
  cidr_block                                 = var.cidr_block
  ami_id_ssm_parameter_name                  = var.ami_id_ssm_parameter_name
  runners_maximum_count                      = var.runners_maximum_count
  sqs_build_queue = {
    arn = module.sqs[0].sqs_build_queue_arn
  }
  create_service_linked_role_spot = var.create_service_linked_role_spot
  enable_organization_runners     = var.enable_organization_runners
  cloudwatch_config               = var.cloudwatch_config
  runner_log_files                = var.runner_log_files
  pool_config                     = var.pool_config
  app_id_arn                      = module.ssm[0].github_app_id_arn
  app_id_name                     = module.ssm[0].github_app_id_name
  key_arn                         = module.ssm[0].github_app_key_base64_arn
  key_base_name                   = module.ssm[0].github_app_key_base64_name
  webhook_secret_arn              = module.ssm[0].github_app_webhook_secret_arn
  runner_extra_labels             = var.runner_extra_labels

  providers = {
    aws = aws.dev
  }

  depends_on = [
    module.get_lambdas,
    module.test_dev_vpc,
    module.runner_binaries_syncer,
    module.sqs,
    module.ssm
  ]
}

module "webhook" {
  count  = (terraform.workspace == "dev") ? 1 : 0
  source = "../modules/webhook"

  stack_name                       = var.stack_name
  prefix                           = var.prefix
  lambda_runtime                   = var.lambda_runtime
  lambda_timeout                   = var.lambda_timeout
  lambda_architecture              = var.lambda_architecture
  enable_workflow_job_labels_check = var.enable_workflow_job_labels_check
  workflow_job_labels_check_all    = var.workflow_job_labels_check_all
  log_level                        = var.log_level
  log_type                         = var.log_type
  repository_white_list            = var.repository_white_list
  sqs_build_queues = {
    arn = module.sqs[0].sqs_build_queue_arn
    id  = module.sqs[0].sqs_build_queue_id
  }
  sqs_build_queue_fifo = var.sqs_build_queue_fifo
  sqs_workflow_job_queue = {
    arn = "${module.sqs[0].sqs_webhook_events_workflow_job_queue_arn}"
    id  = "${module.sqs[0].sqs_webhook_events_workflow_job_queue_id}"
  }
  logging_retention_in_days     = var.logging_retention_in_days
  github_app_webhook_secret_arn = module.ssm[0].github_app_webhook_secret_arn
  github_app_id_arn             = module.ssm[0].github_app_id_arn
  github_app_key_base64_arn     = module.ssm[0].github_app_key_base64_arn

  providers = {
    aws = aws.dev
  }

  depends_on = [
    module.get_lambdas,
    module.sqs,
    module.ssm
  ]
}





output "runners" {
  value = {
    launch_template_name    = module.runners[*].launch_template.name
    launch_template_id      = module.runners[*].launch_template.id
    launch_template_version = module.runners[*].launch_template.latest_version
    launch_template_ami_id  = module.runners[*].launch_template.image_id
    lambda_up               = module.runners[*].lambda_scale_up
    lambda_down             = module.runners[*].lambda_scale_down
    role_runner             = module.runners[*].role_runner
    role_scale_up           = module.runners[*].role_scale_up
    role_scale_down         = module.runners[*].role_scale_down
    role_pool               = module.runners[*].role_pool
  }
}

output "runner_binaries_syncer" {
  value = var.enable_runner_binaries_syncer ? {
    lambda      = module.runner_binaries_syncer[*].lambda_arn
    lambda_role = module.runner_binaries_syncer[*].lambda_role_arn
    # location    = "s3://${module.runner_binaries_syncer[*].dist_bucket_id}/${module.runner_binaries_syncer[*].dist_bucket.key}"
    bucket = module.runner_binaries_syncer[*].dist_bucket
  } : null
}

output "webhook" {
  value = {
    gateway_api_endpoint  = module.webhook[*].gateway_api_endpoint
    gateway_execution_arn = module.webhook[*].gateway_execution_arn
    gateway_arn           = module.webhook[*].gateway_arn
    gateway_id            = module.webhook[*].gateway_id
  }
}

output "ssm_parameters" {
  value = {
    webhook_secret_arn  = module.ssm[*].github_app_webhook_secret_arn
    webhook_secret_name = module.ssm[*].github_app_webhook_secret_name
    key_base64_name     = module.ssm[*].github_app_key_base64_name
    key_base64_arn      = module.ssm[*].github_app_key_base64_arn
    app_id_name         = module.ssm[*].github_app_id_name
    app_id_arn          = module.ssm[*].github_app_id_arn
  }
}

output "sqs" {
  value = {
    build_queue_arn                       = module.sqs[*].sqs_build_queue_arn
    build_queue_id                        = module.sqs[*].sqs_build_queue_id
    webhook_events_workflow_job_queue_arn = module.sqs[*].sqs_webhook_events_workflow_job_queue_arn
    webhook_events_workflow_job_queue_id  = module.sqs[*].sqs_webhook_events_workflow_job_queue_id
  }
}