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
    key_base64     = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAph5yWvpfuxYNG4f2x0uDe+9zBHquuWiv69gfTdWRJzrRprtDOnjdF+sqQjlNmFylRIISGhMPCM9AUHptJ5DhllRT8q9jKLwqGDx8lDwOwPRtuffuP4PGsV+fdcBgKJWl3Nk0qru3u3cYqxwNhzqtHE125P8VpxE+wsx9CA4iS1mheFWNVcUrR0q+/p296MztRv/ZLFuCQGMy0CcdaRlUfYa8kdWuyvMx+HYtzCdEDnVuhd9qztFfpj8DeN2dshOyj/wkbcuwyGGADO3mbD1dn5m6tqOR8twyAyRhyAaJI77FjJGSVuD0TfnMsO+uWXU1YE14lRU2riMXL+lOfgZKSQIDAQABAoIBAHixpmRzhRpo6x0VrDcgpmdlkiuu90O+zBKO9C+Y+92E3s5FQJM7PWgjdJCpEbehmHIuDvji4AmGizPtv2D/4udWXaf1xhXSoML7L4iEGjQXY6G6gV+kXriAwVrMaxERqXDMX3es69FItqObvjiCaUQnBDtdGl5IKVFfQXiYzFHxoa7LR0+Vikl6McoFOsbeZw5OVnwjSTrHLFO5Bgxp/G+jzHUEX/5ksxfchswzTV5quyEbD8nG7xfyh/E6FUyFhpnnL0z8pDLKNhuETRrxL0YrKW9RjHzfsB6jPVyq69bI629efqd27UY8CBBzz67QxB5XQv4xkNRSTpgOHM6S6AECgYEA0RmuCRnL6Qd7/OMbugozPiq82qdzBJdHKf9Wa2Zv0xM6WE8/0h6/c+A93dVaX1ABwsI2XbjtK7qWYNJn/6TiQA6czUxj8Q5nXY1JMX2sjIDYw6aJN7TY5yvVMTDhqybl8uVHqv+gVn7fDmoACPzab49tGm4H3hZ74opQqbBBsXMCgYEAy2DSPIUb31RtwF1GznidkO8+UsOQuFZw0D2wjopRXzaDH0854MlsmEN9pySYdHoFbRO2jTtGTj/HboBBR/6Y6hQNDedc0V0rHoLFLTGr8drTokZ+2SHnhgho2IFAARNF4t3x6g+9EGeoFfOwgWQAARbsO0jVhfrntMNgnhymtlMCgYEAzVKbC0KycQsxW7wigMb9VGEg+tAMaAioD3wz/tginDA4TXjcIVaiBoW+GjMjP45PfE+6lMM+2H6qpT5WcrgUlnQC0rDdPlo3c6yFn7xZD8qBj3TbLsE9b5oiCOCH58kVaTJs8mN6rRR9sSizCiBH2d4LczVyMkj/sw7AcC+sAjMCgYBNFCbZtQD5RUBLNY7OVbwx39pY97Fzi5857QdrHlT0pu5PAXHIFc7IblvC6wW0r0I7Mstu/1YH9fgZkxYquP0vSeYgrNzqpErhR2J/XGH0SaEH0XvlwwnCLJG/7Exbm/hSoRc8RDa9buuvVipA/6tYvl1Noq76FjuWsK1/fxBX7QKBgFHdCWhvnq3XQzvoAlM+vI9TJZ7z7rPHPVbPgDUXT8fXgt59qW+elWCmGYDbDKCYaeOUm3QxB5dg2Dov8JqKZMl/FtQzrgiQ8iYeLftl936J2QGycdl0pVAcOX2+9OClf4oNMtsokF+RVPLvEtTEiG/24ogtam0cLoYl4/Nfwy/G\n-----END RSA PRIVATE KEY-----"
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
  runner_enable_workflow_job_labels_check = var.runner_enable_workflow_job_labels_check
  create_service_linked_role_spot = var.create_service_linked_role_spot
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

