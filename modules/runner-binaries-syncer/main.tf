locals {
  action_runner_distribution_object_key = "actions-runner-${var.runner_os}.${var.runner_os == "linux" ? "tar.gz" : "zip"}"
  bucket_name                           = "${var.distribution_bucket_name}-${terraform.workspace}"
}

resource "aws_s3_bucket" "action_dist" {
  bucket        = local.bucket_name
  force_destroy = true
  tags = {
    Name        = local.bucket_name
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_public_access_block" "action_dist" {
  bucket                  = aws_s3_bucket.action_dist.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "action_dist_acl" {
  bucket = aws_s3_bucket.action_dist.id
  acl    = "private"
}

output "lambda_arn" {
  value = aws_lambda_function.syncer.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.syncer_lambda.arn
}

output "dist_bucket" {
  value = aws_s3_bucket.action_dist.bucket
}

output "dist_bucket_arn" {
  value = aws_s3_bucket.action_dist.arn
}

output "dist_bucket_id" {
  value = aws_s3_bucket.action_dist.id
}

output "runner_distribution_object_key" {
  value = local.action_runner_distribution_object_key
}