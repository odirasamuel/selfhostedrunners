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
  version = "1.18.0"
  aws_region  = "us-east-2"
  vpc_id      = module.test_vpc.vpc_id
  subnet_ids  = ["${module.test_vpc.private_subnets_1_id}", "${module.test_vpc.private_subnets_2_id}", "${module.test_vpc.private_subnets_3_id}"]
#   environment = "test"
  github_app = {
    key_base64     = "-----BEGIN RSA PRIVATE KEY-----MIIEpQIBAAKCAQEAx8U/oXQZz3JlY0Zc/BskTil+RfKztmnC71Z/sl7YLC90QWZwFwrCKiTacacbXeFiUaHd3+2MCI0GoZCLyA19jKnPv9HziuqnT7NzW4Xjfqtbh7Xyb85//IVDtMcaHF+PNqrIZORSsfAQA6E0lDe/0IsvHGtGi4sp8k0ApVQ4Op06zNwaZaVTk0rWXOdzeOTT2VZuGYOPgxKS1Sox6KVGl3XGnJVRcNdjm+kq9kUcvwqp1ZiIopWkSwOG1487LD6egeHjblIHE9vof4w+6TBvh0fMf/PlxKvSPKAnSjsqvKR3OdQzYLTb/cJlA+wwY6xomVG+Rh7EbFKDoV+lhhyVswIDAQABAoIBAHn3B14/T/LDWPs/Xk3dFFFUK+/wuZ/I+ma9XME9/qUbY9L6A71NqDWqwmNZLvAmRqyoMpogobomv8GsSmsdMWXL1za5rANIOFYErY1XNQmE/SDiCN4SKTm28xtP47Um8nzhz+8pJwPUGTLeHQfQ8Z8VGvIy3KMdl8KDGL3XqWy+s/UHu64A3a3mIida7kmliZLakPDcysMbvztZXXqXdsoTaROIljUYRM78EE4DeT4hPZbOG6idV1/FTFiLBao+fFsBqSWFb8tEhXbfDa1iska+VN63vXI0mS2+UiHeJZrp9NC4qPV8yCrpgvepH4FhMxhiwvQiHrb4Aux9rsVPZYECgYEA/GmN/4WVKO0j5HB32oOg/TZsoYtMp1ObXZ5BqHJUlOWC5f1yWwBjYo6D9stUZjt6z66iUP320m5pVGP8UJMAqmdXJDEzt6+6Qt1KrtUICYjWS3iybLJrg0ZthUH872zTALv2CHjv4tW8xz/q9TadGwefmM3uqv51hPLc3Gfa8gMCgYEAypwlyuNcbwokfOFfg9c4gYoWfAu1SMV/VM0bGiLGnV1txvWTqPxz8NThxCMInvVuju+iFGKPacvVxnc2SJ3fjWrwriX3ZsCevNMIIU/29Mo0n1KsJAP7swnOATV2gzgseIwqHWeKbtt9eosJJP8+uPhPKNRDHy4ynVnSbwOZ1pECgYEApUzfMHKj/1xlwAmjhBfly03kEFswhPgs7D9i0lSlbalscv/q7wuvCnE4nNwF1rmnMPE13YKkLKUgF6MvLvlGW1I38DzEmMvdWEKh0SM0E0JozJ4rgyHJZPwvZzCS251SBc4STvQcbVn6OiZy0cnFU1lHvINIhPUFs151I2ZkLU8CgYEAo5hDN7gvaYVCAwejLPw5pvcNwqldfl3hu2JFcOwFfQj0W8LssHTvVNU/WjSDgH5h/83kDBus+trYSQD29tlqqXBg1+zV/8SmJ4cqOGOt3ufqZ37EeewxbtYK3ZUClV9lIQzj8IwrDenyPmFHR/VE+uucVzZU4DdYLQ9ax8Kbk9ECgYEAvG4jqSfGj+KTSCIYHjc7iV/HD7tURC35T2rrOIJ/h9NDUT7NzJyRLR6/rdxF8fd6VZq89eeeZeHh3NbErP0/WnNtDMBnmyw379TWWJLvZN1W1AKIHHBBhhfi+oNg8p9FoECFfXrOA80JoofopuuwL7S1Zg89H74mUUNx963h/pY=-----END RSA PRIVATE KEY-----"
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

