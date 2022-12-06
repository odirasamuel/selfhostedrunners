# variable "vpc_id" {
#   description = "The VPC for security groups of the action runners."
#   type        = string
# }

# variable "subnet_ids" {
#   description = "List of subnets in which the action runners will be launched, the subnets needs to be subnets in the `vpc_id`."
#   type        = list(string)
# }

variable "prefix" {
  description = "The prefix used for naming resources"
  type        = string
  default     = "github-actions"
}

variable "stack_name" {
  description = "Stack name for which this configuration is used for"
  type        = string
}

variable "distribution_bucket_name" {
  description = "Bucket for storing the action runner distribution."
  type        = string

  # Make sure the bucket name only contains legal characters
  validation {
    error_message = "Only lowercase alphanumeric characters and hyphens allowed in the bucket name."
    condition     = can(regex("^[a-z0-9-]*$", var.distribution_bucket_name))
  }
}

variable "runner_labels" {
  description = "Extra (custom) labels for the runners (GitHub). Separate each label by a comma. Labels checks on the webhook can be enforced by setting `enable_workflow_job_labels_check`. GitHub read-only labels should not be provided."
  type        = string
  default     = ""
}

variable "runner_os" {
  description = "The EC2 Operating System type to use for action runner instances (linux,windows)."
  type        = string
  default     = "linux"

  validation {
    condition     = contains(["linux", "windows"], var.runner_os)
    error_message = "Valid values for runner_os are (linux, windows)."
  }
}

variable "runner_architecture" {
  description = "The platform architecture of the runner instance_type."
  type        = string
  default     = "x64"
  validation {
    condition     = contains(["x64", "arm64"], var.runner_architecture)
    error_message = "`runner_architecture` value not valid, valid values are: `x64` and `arm64`."
  }
}

variable "runner_extra_labels" {
  description = "Extra (custom) labels for the runners (GitHub). Separate each label by a comma. Labels checks on the webhook can be enforced by setting `enable_workflow_job_labels_check`. GitHub read-only labels should not be provided."
  type        = string
  default     = ""
}

variable "enable_organization_runners" {
  description = "Register runners to organization, instead of repo level"
  type        = bool
  default     = false
}

variable "github_app" {
  description = "GitHub app parameters, see your github app. Ensure the key is the base64-encoded `.pem` file (the output of `base64 app.private-key.pem`, not the content of `private-key.pem`)."
  type = object({
    key_base64     = string
    id             = string
    webhook_secret = string
  })
}

variable "scale_down_schedule_expression" {
  description = "Scheduler expression to check every x for scale down."
  type        = string
  default     = "cron(*/5 * * * ? *)"
}

variable "minimum_running_time_in_minutes" {
  description = "The time an ec2 action runner should be running at minimum before terminated if not busy."
  type        = number
  default     = null
}

variable "runner_boot_time_in_minutes" {
  description = "The minimum time for an EC2 runner to boot and register as a runner."
  type        = number
  default     = 5
}

variable "runner_group_name" {
  description = "Name of the runner group."
  type        = string
  default     = "Opentrons-runners"
}

variable "scale_up_reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
  type        = number
  default     = 1
}

variable "lambda_timeout" {
  description = "Time out of the lambda in seconds."
  type        = number
  default     = 300
}

variable "instance_profile_path" {
  description = "The path that will be added to the instance_profile, if not set the environment name will be used."
  type        = string
  default     = null
}

variable "runner_as_root" {
  description = "Run the action runner under the root user. Variable `runner_run_as` will be ignored."
  type        = bool
  default     = false
}

variable "runner_run_as" {
  description = "Run the GitHub actions agent as user."
  type        = string
  default     = "ec2-user"
}

variable "runners_maximum_count" {
  description = "The maximum number of runners that will be created."
  type        = number
  default     = 3
}

variable "enable_runner_detailed_monitoring" {
  description = "Should detailed monitoring be enabled for the runner. Set this to true if you want to use detailed monitoring. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html for details."
  type        = bool
  default     = false
}

variable "enabled_userdata" {
  description = "Should the userdata script be enabled for the runner. Set this to false if you are using your own prebuilt AMI."
  type        = bool
  default     = true
}

variable "userdata_template" {
  description = "Alternative user-data template, replacing the default template. By providing your own user_data you have to take care of installing all required software, including the action runner. Variables userdata_pre/post_install are ignored."
  type        = string
  default     = null
}

variable "userdata_pre_install" {
  type        = string
  default     = ""
  description = "Script to be ran before the GitHub Actions runner is installed on the EC2 instances"
}

variable "userdata_post_install" {
  type        = string
  default     = ""
  description = "Script to be ran after the GitHub Actions runner is installed on the EC2 instances"
}

variable "idle_config" {
  description = "List of time period that can be defined as cron expression to keep a minimum amount of runners active instead of scaling down to 0. By defining this list you can ensure that in time periods that match the cron expression within 5 seconds a runner is kept idle."
  type = list(object({
    cron      = string
    timeZone  = string
    idleCount = number
  }))
  default = []
}

variable "enable_ssm_on_runners" {
  description = "Enable to allow access the runner instances for debugging purposes via SSM. Note that this adds additional permissions to the runner instances."
  type        = bool
  default     = true
}

variable "logging_retention_in_days" {
  description = "Specifies the number of days you want to retain log events for the lambda log group. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 180
}

variable "block_device_mappings" {
  description = "The EC2 instance block device configuration. Takes the following keys: `device_name`, `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops`, `throughput`, `kms_key_id`, `snapshot_id`."
  type = list(object({
    delete_on_termination = bool
    device_name           = string
    volume_size           = number
    volume_type           = string
  }))
  default = [{
    delete_on_termination = true
    device_name           = "/dev/sdf"
    volume_size           = 30
    volume_type           = "gp2"
  }]
}

variable "ami_filter" {
  description = "List of maps used to create the AMI filter for the action runner AMI. By default amazon linux 2 is used."
  type        = map(list(string))
  default     = null
}

variable "ami_owners" {
  description = "The list of owners used to select the AMI of action runner instances."
  type        = list(string)
  default     = ["amazon"]
}

variable "ami_id_ssm_parameter_name" {
  description = "Externally managed SSM parameter (of data type aws:ec2:image) that contains the AMI ID to launch runner instances from. Overrides ami_filter"
  type        = string
  default     = null
}

variable "create_service_linked_role_spot" {
  description = "(optional) create the serviced linked role for spot instances that is required by the scale-up lambda."
  type        = bool
  default     = false
}

variable "runner_iam_role_managed_policy_arns" {
  description = "Attach AWS or customer-managed IAM policies (by ARN) to the runner IAM role"
  type        = list(string)
  default     = []
}

variable "enable_cloudwatch_agent" {
  description = "Enabling the cloudwatch agent on the ec2 runner instances, the runner contains default config. Configuration can be overridden via `cloudwatch_config`."
  type        = bool
  default     = true
}

variable "cloudwatch_config" {
  description = "(optional) Replaces the module default cloudwatch log config. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html for details."
  type        = string
  default     = null
}

variable "runner_log_files" {
  description = "(optional) Replaces the module default cloudwatch log config. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html for details."
  type = list(object({
    log_group_name   = string
    prefix_log_group = bool
    file_path        = string
    log_stream_name  = string
  }))
  default = null
}

variable "lambda_subnet_ids" {
  description = "List of subnets in which the action runners will be launched, the subnets needs to be subnets in the `vpc_id`."
  type        = list(string)
  default     = []
}

variable "runner_additional_security_group_ids" {
  description = "(optional) List of additional security groups IDs to apply to the runner"
  type        = list(string)
  default     = []
}

variable "instance_target_capacity_type" {
  description = "Default lifecycle used for runner instances, can be either `spot` or `on-demand`."
  type        = string
  default     = "spot"
  validation {
    condition     = contains(["spot", "on-demand"], var.instance_target_capacity_type)
    error_message = "The instance target capacity should be either spot or on-demand."
  }
}

variable "instance_allocation_strategy" {
  description = "The allocation strategy for spot instances. AWS recommends to use `capacity-optimized` however the AWS default is `lowest-price`."
  type        = string
  default     = "lowest-price"
  validation {
    condition     = contains(["lowest-price", "diversified", "capacity-optimized", "capacity-optimized-prioritized"], var.instance_allocation_strategy)
    error_message = "The instance allocation strategy does not match the allowed values."
  }
}

variable "instance_max_spot_price" {
  description = "Max price price for spot intances per hour. This variable will be passed to the create fleet as max spot price for the fleet."
  type        = string
  default     = null
}

variable "instance_types" {
  description = "List of instance types for the action runner. Defaults are based on runner_os (amzn2 for linux and Windows Server Core for win)."
  type        = list(string)
  default     = ["m5.large", "c5.large"]
}

variable "repository_white_list" {
  description = "List of repositories allowed to use the github app"
  type        = list(string)
  default     = []
}

variable "log_type" {
  description = "Logging format for lambda logging. Valid values are 'json', 'pretty', 'hidden'. "
  type        = string
  default     = "pretty"
  validation {
    condition = anytrue([
      var.log_type == "json",
      var.log_type == "pretty",
      var.log_type == "hidden",
    ])
    error_message = "`log_type` value not valid. Valid values are 'json', 'pretty', 'hidden'."
  }
}

variable "log_level" {
  description = "Logging level for lambda logging. Valid values are  'silly', 'trace', 'debug', 'info', 'warn', 'error', 'fatal'."
  type        = string
  default     = "info"
  validation {
    condition = anytrue([
      var.log_level == "silly",
      var.log_level == "trace",
      var.log_level == "debug",
      var.log_level == "info",
      var.log_level == "warn",
      var.log_level == "error",
      var.log_level == "fatal",
    ])
    error_message = "`log_level` value not valid. Valid values are 'silly', 'trace', 'debug', 'info', 'warn', 'error', 'fatal'."
  }
}

variable "metadata_options" {
  description = "Metadata options for the ec2 runner instances."
  type        = map(any)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
  }
}

variable "enable_ephemeral_runners" {
  description = "Enable ephemeral runners, runners will only be used once."
  type        = bool
  default     = false
}

variable "enable_job_queued_check" {
  description = "Only scale if the job event received by the scale up lambda is is in the state queued. By default enabled for non ephemeral runners and disabled for ephemeral. Set this variable to overwrite the default behavior."
  type        = bool
  default     = null
}

variable "enable_managed_runner_security_group" {
  description = "Enabling the default managed security group creation. Unmanaged security groups can be specified via `runner_additional_security_group_ids`."
  type        = bool
  default     = true
}

variable "pool_lambda_timeout" {
  description = "Time out for the pool lambda in seconds."
  type        = number
  default     = 300
}

variable "pool_runner_owner" {
  description = "The pool will deploy runners to the GitHub org ID, set this value to the org to which you want the runners deployed. Repo level is not supported."
  type        = string
  default     = "Opentrons"
}

variable "pool_lambda_reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
  type        = number
  default     = 1
}

variable "pool_config" {
  description = "The configuration for updating the pool. The `pool_size` to adjust to by the events triggered by the `schedule_expression`. For example you can configure a cron expression for week days to adjust the pool to 10 and another expression for the weekend to adjust the pool to 1."
  type = list(object({
    schedule_expression = string
    size                = number
  }))
  default = []
}

variable "aws_partition" {
  description = "(optiona) partition in the arn namespace to use if not 'aws'"
  type        = string
  default     = "aws"
}

variable "disable_runner_autoupdate" {
  description = "Disable the auto update of the github runner agent. Be-aware there is a grace period of 30 days, see also the [GitHub article](https://github.blog/changelog/2022-02-01-github-actions-self-hosted-runners-can-now-disable-automatic-updates/)"
  type        = bool
  default     = false
}

variable "lambda_runtime" {
  description = "AWS Lambda runtime."
  type        = string
  default     = "nodejs16.x"
}

variable "lambda_architecture" {
  description = "AWS Lambda architecture. Lambda functions using Graviton processors ('arm64') tend to have better price/performance than 'x86_64' functions. "
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["arm64", "x86_64"], var.lambda_architecture)
    error_message = "`lambda_architecture` value is not valid, valid values are: `arm64` and `x86_64`."
  }
}

variable "enable_runner_binaries_syncer" {
  description = "Option to disable the lambda to sync GitHub runner distribution, useful when using a pre-build AMI."
  type        = bool
  default     = true
}

# variable "sqs_build_queues" {
#   description = "SQS queue to publish accepted build events."
#   type = object({
#     id  = string
#     arn = string
#   })
# }

variable "cidr_block" {
  description = "CIDR block of VPC"
  type        = map(string)
}

variable "public_subnets_cidr" {
  description = "Public Subnets CIDRs"
  type        = map(list(string))
}

variable "private_subnets_cidr" {
  description = "Private Subnets CIDRs"
  type        = map(list(string))
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

variable "private_subnets_count" {
  description = "Number of private subnets to be created"
  type        = map(number)
}

variable "public_subnets_count" {
  description = "Number of public subnets to be created"
  type        = map(number)
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to be created"
  type        = map(number)
}

variable "elastic_ips" {
  description = "Number of required Elastic IPs to allocate to NAT Gateways, must be equal to the number of NAT Gateways"
  type        = map(number)
}

variable "lambda_schedule_expression" {
  description = "Scheduler expression for action runner binary syncer."
  type        = string
  default     = "cron(27 * * * ? *)"
}

# variable "s3_runner_binaries" {
#   description = "Bucket details for cached GitHub binary."
#   type = object({
#     arn = string
#     id  = string
#     key = string
#   })
# }

variable "lambda_timeout_scale_down" {
  description = "Time out for the scale down lambda in seconds."
  type        = number
  default     = 300
}

# variable "sqs_build_queue" {
#   description = "SQS queue to consume accepted build events."
#   type = object({
#     arn = string
#   })
# }

variable "sqs_build_queue_fifo" {
  description = "Enable a FIFO queue to remain the order of events received by the webhook. Suggest to set to true for repo level runners."
  type        = bool
  default     = false
}

variable "sqs_workflow_job_queue" {
  description = "SQS queue to monitor github events."
  type = object({
    id  = string
    arn = string
  })
  default = null
}

# variable "github_app_webhook_secret_arn" {
#   description = "Github App Webhook Secret ARN"
#   type        = string
# }

variable "runners_scale_up_lambda_timeout" {
  description = "Time out for the scale up lambda in seconds."
  type        = number
  default     = 300
}

variable "delay_webhook_event" {
  description = "The number of seconds the event accepted by the webhook is invisible on the queue before the scale up lambda will receive the event."
  type        = number
  default     = 30
}

variable "job_queue_retention_in_seconds" {
  description = "The number of seconds the job is held in the queue before it is purged"
  type        = number
  default     = 86400
}

variable "fifo_build_queue" {
  description = "Enable a FIFO queue to remain the order of events received by the webhook. Suggest to set to true for repo level runners."
  type        = bool
  default     = false
}

variable "redrive_build_queue" {
  description = "Set options to attach (optional) a dead letter queue to the build queue, the queue between the webhook and the scale up lambda. You have the following options. 1. Disable by setting `enabled` to false. 2. Enable by setting `enabled` to `true`, `maxReceiveCount` to a number of max retries."
  type = object({
    enabled         = bool
    maxReceiveCount = number
  })
  default = {
    enabled         = false
    maxReceiveCount = null
  }
  validation {
    condition     = var.redrive_build_queue.enabled && var.redrive_build_queue.maxReceiveCount != null || !var.redrive_build_queue.enabled
    error_message = "Ensure you have set the maxReceiveCount when enabled."
  }
}

variable "enable_workflow_job_events_queue" {
  description = "Enabling this experimental feature will create a secondory sqs queue to wich a copy of the workflow_job event will be delivered."
  type        = bool
  default     = false
}

variable "workflow_job_queue_configuration" {
  description = "Configuration options for workflow job queue which is only applicable if the flag enable_workflow_job_events_queue is set to true."
  type = object({
    delay_seconds              = number
    visibility_timeout_seconds = number
    message_retention_seconds  = number
  })
  default = {
    "delay_seconds" : null,
    "visibility_timeout_seconds" : null,
    "message_retention_seconds" : null
  }
}

variable "queue_encryption" {
  description = "Configure how data on queues managed by the modules in ecrypted at REST. Options are encryped via SSE, non encrypted and via KMSS. By default encryptes via SSE is enabled. See for more details the Terraform `aws_sqs_queue` resource https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue."
  type = object({
    sqs_managed_sse_enabled = bool
  })
  default = {
    sqs_managed_sse_enabled = true
  }
}

variable "workflow_job_labels_check_all" {
  description = "If set to true all labels in the workflow job must match the GitHub labels (os, architecture and `self-hosted`). When false if __any__ label matches it will trigger the webhook. `enable_workflow_job_labels_check` must be true for this to take effect."
  type        = bool
  default     = true
}

variable "enable_workflow_job_labels_check" {
  description = "If set to true all labels in the workflow job even are matched against the custom labels and GitHub labels (os, architecture and `self-hosted`). When the labels are not matching the event is dropped at the webhook."
  type        = bool
  default     = true
}

variable "egress_rules" {
  description = "List of egress rules for the GitHub runner instances."
  type = list(object({
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    from_port        = number
    protocol         = string
    to_port          = number
  }))
  default = [{
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
  }]
}

variable "ingress_rules" {
  description = "List of ingress rules for the GitHub runner instances."
  type = list(object({
    cidr_blocks = list(string)
    from_port   = number
    protocol    = string
    to_port     = number
    description = string
  }))
  default = [{
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    description = "SSH"
  }]
}

variable "enable_user_data_debug_logging" {
  description = "Option to enable debug logging for user-data, this logs all secrets as well."
  type        = bool
  default     = false
}

# variable "app_id_arn" {
#   description = "App ID ARN"
#   type        = string
# }

# variable "app_id_name" {
#   description = "App ID Name"
#   type        = string
# }

# variable "key_arn" {
#   description = "Key Base64 ARN"
#   type        = string
# }

# variable "key_base_name" {
#   description = "Key name"
#   type        = string
# }