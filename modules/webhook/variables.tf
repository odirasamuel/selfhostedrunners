variable "prefix" {
  description = "The prefix used for naming resources"
  type        = string
  default     = "github-actions"
}

variable "stack_name" {
  description = "Stack name for which this configuration is used for"
  type        = string
}

variable "github_app_webhook_secret_arn" {
  description = "GitHub App webhook secret ARN"
  type        = string
}

variable "github_app_id_arn" {
  description = "GitHub App ID ARN"
  type        = string
}

variable "github_app_key_base64_arn" {
  description = "GitHub App Key ARN"
  type        = string
}

variable "github_app_client_id_arn" {
  description = "GitHub App Client ID ARN"
  type        = string
}

variable "github_app_client_secret_arn" {
  description = "GitHub App Client Secret ARN"
  type        = string
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

variable "sqs_build_queues" {
  description = "SQS queue to publish accepted build events."
  type = object({
    id  = string
    arn = string
  })
}

variable "sqs_workflow_job_queue" {
  description = "SQS queue to monitor github events."
  type = object({
    id  = string
    arn = string
  })
  default = null
}

variable "lambda_timeout" {
  description = "Time out of the lambda in seconds."
  type        = number
  default     = 300
}

variable "logging_retention_in_days" {
  description = "Specifies the number of days you want to retain log events for the lambda log group. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 7
}

variable "repository_white_list" {
  description = "List of repositories allowed to use the github app"
  type        = list(string)
  default     = []
}

variable "enable_workflow_job_labels_check" {
  description = "If set to true all labels in the workflow job even are matched against the custom labels and GitHub labels (os, architecture and `self-hosted`). When the labels are not matching the event is dropped at the webhook."
  type        = bool
  default     = true
}

variable "workflow_job_labels_check_all" {
  description = "If set to true all labels in the workflow job must match the GitHub labels (os, architecture and `self-hosted`). When false if __any__ label matches it will trigger the webhook. `enable_workflow_job_labels_check` must be true for this to take effect."
  type        = bool
  default     = true
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

variable "sqs_build_queue_fifo" {
  description = "Enable a FIFO queue to remain the order of events received by the webhook. Suggest to set to true for repo level runners."
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