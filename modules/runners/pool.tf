module "pool" {
  count = length(var.pool_config) == 0 ? 0 : 1

  source = "./pool"

  config = {
    prefix                        = var.prefix
    instance_allocation_strategy  = var.instance_allocation_strategy
    instance_max_spot_price       = var.instance_max_spot_price
    instance_target_capacity_type = var.instance_target_capacity_type
    instance_types                = var.instance_types
    cidr_block                    = var.cidr_block
    stack_name                    = var.stack_name
    vpc_id                        = var.vpc_id
    app_id_arn                    = var.app_id_arn
    webhook_secret_arn            = var.webhook_secret_arn
    key_arn                       = var.key_arn
    client_id_arn                 = var.client_id_arn
    client_secret_arn             = var.client_secret_arn
    client_id_name                = var.client_id_name
    client_secret_name            = var.client_secret_name
    app_id_name                   = var.app_id_name
    key_base_name                 = var.key_base_name
    lambda = {
      log_level                 = var.log_level
      log_type                  = var.log_type
      logging_retention_in_days = var.logging_retention_in_days
      # reserved_concurrent_executions = var.pool_lambda_reserved_concurrent_executions
      s3_bucket         = data.aws_s3_object.lambda_s3_bucket.bucket
      s3_key            = data.aws_s3_object.lambda_s3_bucket.key
      s3_object_version = data.aws_s3_object.lambda_s3_bucket.version_id
      subnet_ids        = var.lambda_subnet_ids
      security_group_ids = ["${aws_security_group.runner_sg[0].id}"]
      architecture      = var.lambda_architecture
      runtime           = var.lambda_runtime
      timeout           = var.pool_lambda_timeout
      zip               = data.aws_s3_object.lambda_s3_bucket.key
    }
    pool = var.pool_config
    runner = {
      disable_runner_autoupdate = var.disable_runner_autoupdate
      ephemeral                 = var.enable_ephemeral_runners
      extra_labels              = local.runner_labels
      launch_template           = aws_launch_template.runner
      group_name                = var.runner_group_name
      pool_owner                = var.pool_runner_owner
      role                      = aws_iam_role.runner
    }
    subnet_ids = var.subnet_ids
    tags       = local.tags
  }

  aws_partition = var.aws_partition

}