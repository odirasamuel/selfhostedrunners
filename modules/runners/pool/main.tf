locals {
  tags = {
    Name        = "${var.config.stack_name}-${var.config.prefix}-pool"
    Environment = terraform.workspace
  }
  cidr_block         = var.config.cidr_block[terraform.workspace]
  app_id_arn         = var.config.app_id_arn
  key_base64_arn     = var.config.key_arn
  app_id_name        = var.config.app_id_name
  key_base_name      = var.config.key_base_name
  webhook_secret_arn = var.config.webhook_secret_arn
}

resource "aws_lambda_function" "pool" {

  s3_bucket         = var.config.lambda.s3_bucket != null ? var.config.lambda.s3_bucket : null
  s3_key            = var.config.lambda.s3_key != null ? var.config.lambda.s3_key : null
  s3_object_version = var.config.lambda.s3_object_version != null ? var.config.lambda.s3_object_version : null
  # filename                       = var.config.lambda.s3_bucket == null ? var.config.lambda.zip : null
  source_code_hash               = var.config.lambda.s3_bucket == null ? filebase64sha256(".../modules/download-upload-lambda/runners.zip") : null
  function_name                  = "${var.config.stack_name}-${var.config.prefix}-pool"
  role                           = aws_iam_role.pool.arn
  handler                        = "index.adjustPool"
  architectures                  = [var.config.lambda.architecture]
  runtime                        = var.config.lambda.runtime
  timeout                        = var.config.lambda.timeout
  reserved_concurrent_executions = var.config.lambda.reserved_concurrent_executions
  memory_size                    = 512
  tags                           = local.tags

  environment {
    variables = {
      DISABLE_RUNNER_AUTOUPDATE            = var.config.runner.disable_runner_autoupdate
      ENABLE_EPHEMERAL_RUNNERS             = var.config.runner.ephemeral
      ENVIRONMENT                          = terraform.workspace
      INSTANCE_ALLOCATION_STRATEGY         = var.config.instance_allocation_strategy
      INSTANCE_MAX_SPOT_PRICE              = var.config.instance_max_spot_price
      INSTANCE_TARGET_CAPACITY_TYPE        = var.config.instance_target_capacity_type
      INSTANCE_TYPES                       = join(",", var.config.instance_types)
      LAUNCH_TEMPLATE_NAME                 = var.config.runner.launch_template.name
      LOG_LEVEL                            = var.config.lambda.log_level
      LOG_TYPE                             = var.config.lambda.log_type
      PARAMETER_GITHUB_APP_ID_NAME         = local.app_id_name
      PARAMETER_GITHUB_APP_KEY_BASE64_NAME = local.key_base_name
      RUNNER_EXTRA_LABELS                  = var.config.runner.extra_labels
      RUNNER_GROUP_NAME                    = var.config.runner.group_name
      RUNNER_OWNER                         = var.config.runner.pool_owner
      SUBNET_IDS                           = join(",", var.config.subnet_ids)
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.runner_pool_sg.id]
    subnet_ids         = var.config.subnet_ids
  }
}

resource "aws_cloudwatch_log_group" "pool" {
  name              = "/aws/lambda/${aws_lambda_function.pool.function_name}"
  retention_in_days = var.config.lambda.logging_retention_in_days

  tags = local.tags
}

resource "aws_iam_role" "pool" {
  name               = "${var.config.stack_name}-action-pool-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy" "pool" {
  name = "${var.config.stack_name}-${var.config.prefix}-lambda-pool-policy"
  role = aws_iam_role.pool.name
  policy = templatefile("${path.module}/policies/lambda-pool.json", {
    all_arn = "*"
  })
}

resource "aws_iam_role_policy" "pool_logging" {
  name = "${var.config.stack_name}-${var.config.prefix}-lambda-logging"
  role = aws_iam_role.pool.name
  policy = templatefile("${path.module}/../policies/lambda-cloudwatch.json", {
    log_group_arn = "${aws_cloudwatch_log_group.pool.arn}",
    other_arn     = "*"
  })
}

resource "aws_iam_role_policy_attachment" "pool_vpc_execution_role" {
  count      = length(var.config.lambda.subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.pool.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
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

# per config object one trigger is created to trigger the lambda.
resource "aws_cloudwatch_event_rule" "pool" {
  count = length(var.config.pool)

  name                = "${var.config.stack_name}-${var.config.prefix}-pool-${count.index}-rule"
  schedule_expression = var.config.pool[count.index].schedule_expression
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "pool" {
  count = length(var.config.pool)

  input = jsonencode({
    poolSize = var.config.pool[count.index].size
  })

  rule = aws_cloudwatch_event_rule.pool[count.index].name
  arn  = aws_lambda_function.pool.arn
}

resource "aws_lambda_permission" "pool" {
  count = length(var.config.pool)

  statement_id  = "AllowExecutionFromCloudWatch-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pool.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pool[count.index].arn
}

resource "aws_security_group" "runner_pool_sg" {
  name        = "${var.config.stack_name}-${var.config.prefix}-runner-pool-sg"
  description = "Github Actions Runner Pool security group"

  vpc_id = var.config.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${local.cidr_block}"]
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


output "role_pool" {
  value = aws_iam_role.pool
}