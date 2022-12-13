locals {
  app_id_arn         = var.app_id_arn
  key_base64_arn     = var.key_arn
  webhook_secret_arn = var.webhook_secret_arn
  app_id_name        = var.app_id_name
  key_base_name      = var.key_base_name
  client_id_name     = var.client_id_name
  client_id_arn      = var.client_id_arn
  client_secret_name = var.client_secret_name
  client_secret_arn  = var.client_secret_arn
}

resource "aws_lambda_function" "scale_up" {
  s3_bucket         = data.aws_s3_object.lambda_s3_bucket.bucket
  s3_key            = data.aws_s3_object.lambda_s3_bucket.key
  s3_object_version = data.aws_s3_object.lambda_s3_bucket.version_id
  # filename                       = data.aws_s3_object.lambda_s3_bucket.key
  source_code_hash               = filebase64sha256("../modules/download-upload-lambda/runners.zip")
  function_name                  = "${var.stack_name}-${var.prefix}-scale-up"
  role                           = aws_iam_role.scale_up.arn
  handler                        = "index.scaleUpHandler"
  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_timeout_scale_up
  reserved_concurrent_executions = var.scale_up_reserved_concurrent_executions
  memory_size                    = 512
  tags                           = local.tags
  architectures                  = [var.lambda_architecture]

  environment {
    variables = {
      DISABLE_RUNNER_AUTOUPDATE               = var.disable_runner_autoupdate
      ENABLE_EPHEMERAL_RUNNERS                = var.enable_ephemeral_runners
      ENABLE_JOB_QUEUED_CHECK                 = local.enable_job_queued_check
      ENABLE_ORGANIZATION_RUNNERS             = var.enable_organization_runners
      ENVIRONMENT                             = terraform.workspace
      INSTANCE_ALLOCATION_STRATEGY            = var.instance_allocation_strategy
      INSTANCE_MAX_SPOT_PRICE                 = var.instance_max_spot_price
      INSTANCE_TARGET_CAPACITY_TYPE           = var.instance_target_capacity_type
      INSTANCE_TYPES                          = join(",", var.instance_types)
      LAUNCH_TEMPLATE_NAME                    = aws_launch_template.runner.name
      LOG_LEVEL                               = var.log_level
      LOG_TYPE                                = var.log_type
      PARAMETER_GITHUB_APP_ID_NAME            = local.app_id_name
      PARAMETER_GITHUB_APP_KEY_BASE64_NAME    = local.key_base_name
      PARAMETER_GITHUB_APP_CLIENT_ID_NAME     = local.client_id_name
      PARAMETER_GITHUB_APP_CLIENT_SECRET_NAME = local.client_secret_name
      RUNNER_EXTRA_LABELS                     = local.runner_labels
      RUNNER_GROUP_NAME                       = var.runner_group_name
      RUNNERS_MAXIMUM_COUNT                   = var.runners_maximum_count
      SUBNET_IDS                              = join(",", var.subnet_ids)
      AMI_ID_SSM_PARAMETER_NAME               = var.ami_id_ssm_parameter_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.runner_scale_up_down_sg.id]
    subnet_ids         = var.lambda_subnet_ids
  }
}

resource "aws_cloudwatch_log_group" "scale_up" {
  name              = "/aws/lambda/${aws_lambda_function.scale_up.function_name}"
  retention_in_days = var.logging_retention_in_days

  tags = local.tags
}

resource "aws_lambda_event_source_mapping" "scale_up" {
  event_source_arn = var.sqs_build_queue.arn
  function_name    = aws_lambda_function.scale_up.arn
  batch_size       = 1
}

resource "aws_lambda_permission" "scale_runners_lambda" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scale_up.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.sqs_build_queue.arn
}

resource "aws_iam_role" "scale_up" {
  name               = "${var.stack_name}-${var.prefix}-scale-up-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy" "scale_up" {
  name = "${var.stack_name}-${var.prefix}-lambda-scale-up-policy"
  role = aws_iam_role.scale_up.name
  policy = templatefile("${path.module}/policies/lambda-scale-up.json", {
    arn_runner_instance_role      = aws_iam_role.runner.arn
    sqs_arn                       = var.sqs_build_queue.arn
    github_app_webhook_secret_arn = var.webhook_secret_arn
    github_app_id_arn             = var.app_id_arn
    github_app_key_base64_arn     = var.key_arn
    github_app_client_id_arn      = var.client_id_arn
    github_app_client_secret_arn  = var.client_secret_arn
    other_arn                     = "*"
    all_arn                       = "*"
  })
}


resource "aws_iam_role_policy" "scale_up_logging" {
  name = "${var.stack_name}-${var.prefix}-lambda-scale-up-logging"
  role = aws_iam_role.scale_up.name
  policy = templatefile("${path.module}/policies/lambda-cloudwatch.json", {
    log_group_arn = "${aws_cloudwatch_log_group.scale_up.arn}",
    other_arn     = "*"
  })
}

resource "aws_iam_role_policy" "service_linked_role" {
  count = var.create_service_linked_role_spot ? 1 : 0
  name  = "${var.stack_name}-${var.prefix}-service_linked_role"
  role  = aws_iam_role.scale_up.name
  policy = templatefile("${path.module}/policies/service-linked-role-create-policy.json", {
    aws_partition = "${var.aws_partition}",
    other_arn     = "*"
  })
}

resource "aws_iam_role_policy_attachment" "scale_up_vpc_execution_role" {
  count      = length(var.lambda_subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.scale_up.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "ami_id_ssm_parameter_read" {
  count  = var.ami_id_ssm_parameter_name != null ? 1 : 0
  name   = "${var.stack_name}-${var.prefix}-ami-id-ssm-parameter-read"
  role   = aws_iam_role.scale_up.name
  policy = <<-JSON
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ssm:GetParameter"
          ],
          "Resource": [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${trimprefix(var.ami_id_ssm_parameter_name, "/")}",
            "*"
          ]
        }
      ]
    }
  JSON
}