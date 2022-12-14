variable "stack_name" {
  description = "Stack name for which this configuration is used for"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block of VPC"
  type        = map(string)
}

variable "public_subnets_count" {
  description = "Number of public subnets to be created"
  type        = map(number)
}

variable "public_subnets_cidr" {
  description = "Public Subnets CIDRs"
  type        = map(list(string))
}

variable "private_subnets_count" {
  description = "Number of private subnets to be created"
  type        = map(number)
}

variable "private_subnets_cidr" {
  description = "Private Subnets CIDRs"
  type        = map(list(string))
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to be created"
  type        = map(number)
}

variable "elastic_ips" {
  description = "Number of required Elastic IPs to allocate to NAT Gateways, must be equal to the number of NAT Gateways"
  type        = map(number)
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

variable "scale_up_reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
  type        = number
  default     = -1
}

variable "pool_lambda_reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
  type        = number
  default     = -1
}

variable "runner_enable_workflow_job_labels_check" {
  description = "If set to true all labels in the workflow job even are matched against the custom labels and GitHub labels (os, architecture and `self-hosted`). When the labels are not matching the event is dropped at the webhook."
  type        = bool
  default     = true
}

variable "create_service_linked_role_spot" {
  description = "(optional) create the serviced linked role for spot instances that is required by the scale-up lambda."
  type        = bool
  default     = true
}

# variable "instance_target_capacity_type" {
#   description = "Default lifecyle used runner instances, can be either `spot` or `on-demand`."
#   type        = string
#   default     = "on-demand"

#   validation {
#     condition     = contains(["spot", "on-demand"], var.instance_target_capacity_type)
#     error_message = "The instance target capacity should be either spot or on-demand."
#   }
# }