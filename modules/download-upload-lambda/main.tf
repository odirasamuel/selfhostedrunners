data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  lambda_bucket = "${var.stack_name}-${var.prefix}-${terraform.workspace}-bucket"
}

resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = local.lambda_bucket

  tags = {
    Name        = local.lambda_bucket
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_acl" "lambda_s3_bucket" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "runner_binaries_syncer_lambda_zip" {
  bucket = aws_s3_bucket.lambda_s3_bucket.bucket
  key    = "runner-binaries-syncer.zip"
  source = "../modules/download-upload-lambda/runner-binaries-syncer.zip"
  etag   = filemd5("../modules/download-upload-lambda/runner-binaries-syncer.zip")
}

resource "aws_s3_object" "runners_lambda_zip" {
  bucket = aws_s3_bucket.lambda_s3_bucket.bucket
  key    = "runners.zip"
  source = "../modules/download-upload-lambda/runners.zip"
  etag   = filemd5("../modules/download-upload-lambda/runners.zip")
}

resource "aws_s3_object" "webhook_lambda_zip" {
  bucket = aws_s3_bucket.lambda_s3_bucket.bucket
  key    = "webhook.zip"
  source = "../modules/download-upload-lambda/webhook.zip"
  etag   = filemd5("../modules/download-upload-lambda/webhook.zip")
}








output "runner_binaries_syncer_lambda_zip" {
  value = aws_s3_object.runner_binaries_syncer_lambda_zip.key
}

output "runners_lambda_zip" {
  value = aws_s3_object.runners_lambda_zip.key
}

output "webhook_lambda_zip" {
  value = aws_s3_object.webhook_lambda_zip.key
}

output "lambda_s3_bucket" {
  value = aws_s3_bucket.lambda_s3_bucket.bucket
}

output "runner_binaries_syncer_lambda_zip_version_id" {
  value = aws_s3_object.runner_binaries_syncer_lambda_zip.version_id
}

output "runners_lambda_zip_version_id" {
  value = aws_s3_object.runners_lambda_zip.version_id
}

output "webhook_lambda_zip_version_id" {
  value = aws_s3_object.webhook_lambda_zip.version_id
}