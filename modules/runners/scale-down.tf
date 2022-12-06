locals {
  gh_binary_os_label   = "linux"
  min_runtime_defaults = 5
}


resource "aws_lambda_function" "scale_down" {
  s3_bucket         = data.aws_s3_object.lambda_s3_bucket.bucket
  s3_key            = data.aws_s3_object.lambda_s3_bucket.key
  s3_object_version = data.aws_s3_object.lambda_s3_bucket.version_id
  # filename          = data.aws_s3_object.lambda_s3_bucket.key
  source_code_hash = filebase64sha256("../modules/download-upload-lambda/runners.zip")
  function_name    = "${var.stack_name}-${var.prefix}-scale-down"
  role             = aws_iam_role.scale_down.arn
  handler          = "index.scaleDownHandler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout_scale_down
  tags             = local.tags
  memory_size      = 512
  architectures    = [var.lambda_architecture]

  environment {
    variables = {
      ENVIRONMENT                          = terraform.workspace
      LOG_LEVEL                            = var.log_level
      LOG_TYPE                             = var.log_type
      MINIMUM_RUNNING_TIME_IN_MINUTES      = coalesce(var.minimum_running_time_in_minutes, local.min_runtime_defaults)
      PARAMETER_GITHUB_APP_ID_NAME         = local.app_id_name
      PARAMETER_GITHUB_APP_KEY_BASE64_NAME = local.key_base_name
      RUNNER_BOOT_TIME_IN_MINUTES          = var.runner_boot_time_in_minutes
      SCALE_DOWN_CONFIG                    = jsonencode(var.idle_config)
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.runner_scale_up_down_sg.id]
    subnet_ids         = var.lambda_subnet_ids
  }
}

resource "aws_cloudwatch_log_group" "scale_down" {
  name              = "/aws/lambda/${aws_lambda_function.scale_down.function_name}"
  retention_in_days = var.logging_retention_in_days

  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "scale_down" {
  name                = "${var.stack_name}-${var.prefix}-scale-down-rule"
  schedule_expression = var.scale_down_schedule_expression
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "scale_down" {
  rule = aws_cloudwatch_event_rule.scale_down.name
  arn  = aws_lambda_function.scale_down.arn
}

resource "aws_lambda_permission" "scale_down" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scale_down.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scale_down.arn
}

resource "aws_iam_role" "scale_down" {
  name               = "${var.stack_name}-${var.prefix}-scale-down-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy" "scale_down" {
  name = "${var.stack_name}-${var.prefix}-lambda-scale-down-policy"
  role = aws_iam_role.scale_down.name
  policy = templatefile("${path.module}/policies/lambda-scale-down.json", {
    all_arn = "*"
  })
}

resource "aws_iam_role_policy" "scale_down_logging" {
  name = "${var.stack_name}-${var.prefix}-lambda-scale-down-logging"
  role = aws_iam_role.scale_down.name
  policy = templatefile("${path.module}/policies/lambda-cloudwatch.json", {
    log_group_arn = "${aws_cloudwatch_log_group.scale_down.arn}",
    other_arn     = "*"
  })
}

resource "aws_iam_role_policy_attachment" "scale_down_vpc_execution_role" {
  count      = length(var.lambda_subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.scale_down.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "runner_scale_up_down_sg" {
  name        = "${var.stack_name}-${var.prefix}-runner-scale-up-down-sg"
  description = "Github Actions Runner Scale Down security group"

  vpc_id = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}