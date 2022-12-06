variable "config" {
  type = object({
    lambda = object({
      log_level                      = string
      log_type                       = string
      logging_retention_in_days      = number
      reserved_concurrent_executions = number
      s3_bucket                      = string
      s3_key                         = string
      s3_object_version              = string
      runtime                        = string
      architecture                   = string
      timeout                        = number
      zip                            = string
      subnet_ids                     = list(string)
    })
    subnet_ids = list(string)
    runner = object({
      disable_runner_autoupdate = bool
      ephemeral                 = bool
      extra_labels              = string
      launch_template = object({
        name = string
      })
      group_name = string
      pool_owner = string
    })
    instance_types                = list(string)
    instance_target_capacity_type = string
    instance_allocation_strategy  = string
    instance_max_spot_price       = string
    prefix                        = string
    stack_name                    = string
    vpc_id                        = string
    cidr_block                    = map(string)
    app_id_arn                    = string
    webhook_secret_arn            = string
    key_arn                       = string
    app_id_name                   = string
    key_base_name                 = string
    pool = list(object({
      schedule_expression = string
      size                = number
    }))
  })
}

variable "aws_partition" {
  description = "(optional) partition for the arn if not 'aws'"
  type        = string
  default     = "aws"
}