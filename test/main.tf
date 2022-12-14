module "test_vpc" {
  source = "../modules/vpc"

  availability_zones    = var.availability_zones
  cidr_block            = var.cidr_block
  public_subnets_count  = var.public_subnets_count
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_count = var.private_subnets_count
  private_subnets_cidr  = var.private_subnets_cidr
  nat_gateway_count     = var.nat_gateway_count
  elastic_ips           = var.elastic_ips
  stack_name            = var.stack_name

  providers = {
    aws = aws.test
   }
}

module "runners" {
  source  = "philips-labs/github-runner/aws"
  version = "1.16.1"
  aws_region  = "us-east-2"
  vpc_id      = module.test_vpc.vpc_id
  subnet_ids  = ["${module.test_vpc.private_subnets_1_id}", "${module.test_vpc.private_subnets_2_id}", "${module.test_vpc.private_subnets_3_id}"]
#   environment = "test"
  github_app = {
    key_base64     = "odi-selfhosted-github-app.2022-12-07.private-key.pem"
    id             = "269936"
    client_id      = "Iv1.20a3a1deb4920291"
    client_secret  = "3e6185fc6116fd655242304ed3a74463848abf40"
    webhook_secret = "OdiWebhookSecret07122022"
  }
  webhook_lambda_zip                = "../modules/download-upload-lambda/webhook.zip"
  runner_binaries_syncer_lambda_zip = "../modules/download-upload-lambda/runner-binaries-syncer.zip"
  runners_lambda_zip                = "../modules/download-upload-lambda/runners.zip"
  enable_organization_runners       = false
  scale_up_reserved_concurrent_executions = var.scale_up_reserved_concurrent_executions
  pool_lambda_reserved_concurrent_executions = var.pool_lambda_reserved_concurrent_executions
#   instance_target_capacity_type = var.instance_target_capacity_type

  providers = {
    aws = aws.test
   }
}


output "lambda_syncer_name" {
  value = module.runners.binaries_syncer.lambda.function_name
}
output "webhook" {
  value = {
    endpoint = module.runners.webhook.endpoint
  }
}