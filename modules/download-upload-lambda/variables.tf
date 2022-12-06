variable "stack_name" {
  description = "Stack name for which this configuration is used for"
  type        = string
}

variable "prefix" {
  description = "The prefix used for naming resources"
  type        = string
  default     = "github-actions"
}