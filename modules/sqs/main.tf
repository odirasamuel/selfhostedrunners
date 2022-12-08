locals {
  tags = {
    Name        = "${var.stack_name}-${var.prefix}-sqs"
    Environment = terraform.workspace
  }
}

data "aws_iam_policy_document" "deny_unsecure_transport" {
  statement {
    sid = "DenyUnsecureTransport"

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:*"
    ]

    resources = [
      "*"
    ]

    # condition {
    #   test     = "Bool"
    #   variable = "aws:SecureTransport"
    #   values   = ["false"]
    # }
  }
}

resource "aws_sqs_queue_policy" "build_queue_policy" {
  queue_url = aws_sqs_queue.queued_builds.id
  policy    = data.aws_iam_policy_document.deny_unsecure_transport.json
}

resource "aws_sqs_queue_policy" "webhook_events_workflow_job_queue_policy" {
  count     = var.enable_workflow_job_events_queue ? 1 : 0
  queue_url = aws_sqs_queue.webhook_events_workflow_job_queue[0].id
  policy    = data.aws_iam_policy_document.deny_unsecure_transport.json
}

resource "aws_sqs_queue" "queued_builds" {
  name                        = "${var.stack_name}-${var.prefix}-queued-builds${var.fifo_build_queue ? ".fifo" : ""}"
  delay_seconds               = var.delay_webhook_event
  visibility_timeout_seconds  = var.runners_scale_up_lambda_timeout
  message_retention_seconds   = var.job_queue_retention_in_seconds
  fifo_queue                  = var.fifo_build_queue
  receive_wait_time_seconds   = 0
  content_based_deduplication = var.fifo_build_queue
  redrive_policy = var.redrive_build_queue.enabled ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queued_builds_dlq[0].arn,
    maxReceiveCount     = var.redrive_build_queue.maxReceiveCount
  }) : null
  sqs_managed_sse_enabled = var.queue_encryption.sqs_managed_sse_enabled

  tags = local.tags
}

resource "aws_sqs_queue" "webhook_events_workflow_job_queue" {
  count                       = var.enable_workflow_job_events_queue ? 1 : 0
  name                        = "${var.stack_name}-${var.prefix}-webhook_events_workflow_job_queue"
  delay_seconds               = var.workflow_job_queue_configuration.delay_seconds
  visibility_timeout_seconds  = var.workflow_job_queue_configuration.visibility_timeout_seconds
  message_retention_seconds   = var.workflow_job_queue_configuration.message_retention_seconds
  fifo_queue                  = false
  receive_wait_time_seconds   = 0
  content_based_deduplication = false
  redrive_policy              = null
  sqs_managed_sse_enabled     = var.queue_encryption.sqs_managed_sse_enabled

  tags = local.tags
}

resource "aws_sqs_queue_policy" "build_queue_dlq_policy" {
  count     = var.redrive_build_queue.enabled ? 1 : 0
  queue_url = aws_sqs_queue.queued_builds.id
  policy    = data.aws_iam_policy_document.deny_unsecure_transport.json
}

resource "aws_sqs_queue" "queued_builds_dlq" {
  count                   = var.redrive_build_queue.enabled ? 1 : 0
  name                    = "${var.stack_name}-${var.prefix}-queued-builds_dead_letter"
  sqs_managed_sse_enabled = var.queue_encryption.sqs_managed_sse_enabled

  tags = local.tags
}

output "sqs_build_queue_arn" {
  value = aws_sqs_queue.queued_builds.arn
}

output "sqs_build_queue_id" {
  value = aws_sqs_queue.queued_builds.id
}

output "sqs_webhook_events_workflow_job_queue_arn" {
  value = try("${aws_sqs_queue.webhook_events_workflow_job_queue[0]}", null) != null ? "${aws_sqs_queue.webhook_events_workflow_job_queue[0].arn}" : "*"
}

output "sqs_webhook_events_workflow_job_queue_id" {
  value = try("${aws_sqs_queue.webhook_events_workflow_job_queue[0]}", null) != null ? "${aws_sqs_queue.webhook_events_workflow_job_queue[0].id}" : "*"
}

output "sqs_build_dlq_arn" {
  value = "${var.redrive_build_queue.enabled}" ? "${aws_sqs_queue.queued_builds_dlq[0].arn}" : null
}
