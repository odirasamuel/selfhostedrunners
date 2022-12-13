resource "aws_lambda_function" "webhook" {
  s3_bucket         = data.aws_s3_object.lambda_s3_bucket.bucket
  s3_key            = data.aws_s3_object.lambda_s3_bucket.key
  s3_object_version = data.aws_s3_object.lambda_s3_bucket.version_id
  # filename          = data.aws_s3_object.lambda_s3_bucket.key
  source_code_hash = filebase64sha256("../modules/download-upload-lambda/webhook.zip")
  function_name    = "${var.stack_name}-${var.prefix}-webhook"
  role             = aws_iam_role.webhook_lambda.arn
  handler          = "index.githubWebhook"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = 512
  architectures    = [var.lambda_architecture]

  environment {
    variables = {
      ENABLE_WORKFLOW_JOB_LABELS_CHECK = var.enable_workflow_job_labels_check
      WORKFLOW_JOB_LABELS_CHECK_ALL    = var.workflow_job_labels_check_all
      ENVIRONMENT                      = terraform.workspace
      LOG_LEVEL                        = var.log_level
      LOG_TYPE                         = var.log_type
      REPOSITORY_WHITE_LIST            = jsonencode(var.repository_white_list)
      RUNNER_LABELS                    = local.runner_labels
      SQS_URL_WEBHOOK                  = var.sqs_build_queues.id
      SQS_IS_FIFO                      = var.sqs_build_queue_fifo
      SQS_WORKFLOW_JOB_QUEUE           = try(var.sqs_workflow_job_queue, null) != null ? var.sqs_workflow_job_queue.id : ""
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "webhook" {
  name              = "/aws/lambda/${aws_lambda_function.webhook.function_name}"
  retention_in_days = var.logging_retention_in_days

  tags = local.tags
}

resource "aws_lambda_permission" "webhook" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.webhook.execution_arn}/*/*/${local.webhook_endpoint}"
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

resource "aws_iam_role" "webhook_lambda" {
  name               = "${var.stack_name}-${var.prefix}-webhook-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy" "webhook_logging" {
  name = "${var.stack_name}-${var.prefix}-lambda-logging-policy"
  role = aws_iam_role.webhook_lambda.name
  policy = templatefile("${path.module}/policies/lambda-cloudwatch.json", {
    log_group_arn = "${aws_cloudwatch_log_group.webhook.arn}",
    other_arn     = "*"
  })
}

resource "aws_iam_role_policy" "webhook_sqs" {
  name = "${var.stack_name}-${var.prefix}-lambda-webhook-publish-sqs-policy"
  role = aws_iam_role.webhook_lambda.name

  policy = templatefile("${path.module}/policies/lambda-publish-sqs-policy.json", {
    sqs_resource_arn = "${var.sqs_build_queues.arn}",
    other_arn        = "*"
  })
}

resource "aws_iam_role_policy" "webhook_workflow_job_sqs" {
  count = var.sqs_workflow_job_queue != null ? 1 : 0
  name  = "${var.stack_name}-${var.prefix}-lambda-webhook-publish-workflow-job-sqs-policy"
  role  = aws_iam_role.webhook_lambda.name

  policy = templatefile("${path.module}/policies/lambda-publish-sqs-policy.json", {
    sqs_resource_arn = "${var.sqs_workflow_job_queue.arn}",
    other_arn        = "*"
  })
}

resource "aws_iam_role_policy" "webhook_ssm" {
  name = "${var.stack_name}-${var.prefix}-lambda-webhook-publish-ssm-policy"
  role = aws_iam_role.webhook_lambda.name

  policy = templatefile("${path.module}/policies/lambda-ssm.json", {
    github_app_webhook_secret_arn = var.github_app_webhook_secret_arn
    github_app_id_arn             = var.github_app_id_arn
    github_app_key_base64_arn     = var.github_app_key_base64_arn
    github_app_client_id_arn      = var.github_app_client_id_arn
    github_app_client_secret_arn  = var.github_app_client_secret_arn
    all_arn                       = "*"
  })
}