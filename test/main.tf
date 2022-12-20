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
  source     = "philips-labs/github-runner/aws"
  version    = "1.18.0"
  aws_region = "us-east-2"
  vpc_id     = module.test_vpc.vpc_id
  subnet_ids = ["${module.test_vpc.private_subnets_1_id}", "${module.test_vpc.private_subnets_2_id}", "${module.test_vpc.private_subnets_3_id}"]
  #   environment = "test"
  github_app = {
    key_base64     = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBeDhVL29YUVp6M0psWTBaYy9Cc2tUaWwrUmZLenRtbkM3MVovc2w3WUxDOTBRV1p3CkZ3ckNLaVRhY2FjYlhlRmlVYUhkMysyTUNJMEdvWkNMeUExOWpLblB2OUh6aXVxblQ3TnpXNFhqZnF0Ymg3WHkKYjg1Ly9JVkR0TWNhSEYrUE5xcklaT1JTc2ZBUUE2RTBsRGUvMElzdkhHdEdpNHNwOGswQXBWUTRPcDA2ek53YQpaYVZUazByV1hPZHplT1RUMlZadUdZT1BneEtTMVNveDZLVkdsM1hHbkpWUmNOZGptK2txOWtVY3Z3cXAxWmlJCm9wV2tTd09HMTQ4N0xENmVnZUhqYmxJSEU5dm9mNHcrNlRCdmgwZk1mL1BseEt2U1BLQW5TanNxdktSM09kUXoKWUxUYi9jSmxBK3d3WTZ4b21WRytSaDdFYkZLRG9WK2xoaHlWc3dJREFRQUJBb0lCQUhuM0IxNC9UL0xEV1BzLwpYazNkRkZGVUsrL3d1Wi9JK21hOVhNRTkvcVViWTlMNkE3MU5xRFdxd21OWkx2QW1ScXlvTXBvZ29ib212OEdzClNtc2RNV1hMMXphNXJBTklPRllFclkxWE5RbUUvU0RpQ040U0tUbTI4eHRQNDdVbThuemh6KzhwSndQVUdUTGUKSFFmUThaOFZHdkl5M0tNZGw4S0RHTDNYcVd5K3MvVUh1NjRBM2EzbUlpZGE3a21saVpMYWtQRGN5c01idnp0WgpYWHFYZHNvVGFST0lsalVZUk03OEVFNERlVDRoUFpiT0c2aWRWMS9GVEZpTEJhbytmRnNCcVNXRmI4dEVoWGJmCkRhMWlza2ErVk42M3ZYSTBtUzIrVWlIZUpacnA5TkM0cVBWOHlDcnBndmVwSDRGaE14aGl3dlFpSHJiNEF1eDkKcnNWUFpZRUNnWUVBL0dtTi80V1ZLTzBqNUhCMzJvT2cvVFpzb1l0TXAxT2JYWjVCcUhKVWxPV0M1ZjF5V3dCagpZbzZEOXN0VVpqdDZ6NjZpVVAzMjBtNXBWR1A4VUpNQXFtZFhKREV6dDYrNlF0MUtydFVJQ1lqV1MzaXliTEpyCmcwWnRoVUg4NzJ6VEFMdjJDSGp2NHRXOHh6L3E5VGFkR3dlZm1NM3VxdjUxaFBMYzNHZmE4Z01DZ1lFQXlwd2wKeXVOY2J3b2tmT0ZmZzljNGdZb1dmQXUxU01WL1ZNMGJHaUxHblYxdHh2V1RxUHh6OE5UaHhDTUludlZ1anUraQpGR0tQYWN2VnhuYzJTSjNmaldyd3JpWDNac0Nldk5NSUlVLzI5TW8wbjFLc0pBUDdzd25PQVRWMmd6Z3NlSXdxCkhXZUtidHQ5ZW9zSkpQOCt1UGhQS05SREh5NHluVm5TYndPWjFwRUNnWUVBcFV6Zk1IS2ovMXhsd0FtamhCZmwKeTAza0VGc3doUGdzN0Q5aTBsU2xiYWxzY3YvcTd3dXZDbkU0bk53RjFybW5NUEUxM1lLa0xLVWdGNk12THZsRwpXMUkzOER6RW1NdmRXRUtoMFNNMEUwSm96SjRyZ3lISlpQd3ZaekNTMjUxU0JjNFNUdlFjYlZuNk9pWnkwY25GClUxbEh2SU5JaFBVRnMxNTFJMlprTFU4Q2dZRUFvNWhETjdndmFZVkNBd2VqTFB3NXB2Y053cWxkZmwzaHUySkYKY093RmZRajBXOExzc0hUdlZOVS9XalNEZ0g1aC84M2tEQnVzK3RyWVNRRDI5dGxxcVhCZzErelYvOFNtSjRjcQpPR090M3VmcVozN0VlZXd4YnRZSzNaVUNsVjlsSVF6ajhJd3JEZW55UG1GSFIvVkUrdXVjVnpaVTREZFlMUTlhCng4S2JrOUVDZ1lFQXZHNGpxU2ZHaitLVFNDSVlIamM3aVYvSEQ3dFVSQzM1VDJyck9JSi9oOU5EVVQ3TnpKeVIKTFI2L3JkeEY4ZmQ2VlpxODllZWVaZUhoM05iRXJQMC9Xbk50RE1Cbm15dzM3OVRXV0pMdlpOMVcxQUtJSEhCQgpoaGZpK29OZzhwOUZvRUNGZlhyT0E4MEpvb2ZvcHV1d0w3UzFaZzg5SDc0bVVVTng5NjNoL3BZPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
    id             = "269936"
    client_id      = "Iv1.20a3a1deb4920291"
    client_secret  = "3e6185fc6116fd655242304ed3a74463848abf40"
    webhook_secret = "OdiWebhookSecret07122022"
  }
  webhook_lambda_zip                         = "../modules/download-upload-lambda/webhook.zip"
  runner_binaries_syncer_lambda_zip          = "../modules/download-upload-lambda/runner-binaries-syncer.zip"
  runners_lambda_zip                         = "../modules/download-upload-lambda/runners.zip"
  enable_organization_runners                = false
  scale_up_reserved_concurrent_executions    = var.scale_up_reserved_concurrent_executions
  pool_lambda_reserved_concurrent_executions = var.pool_lambda_reserved_concurrent_executions
  runner_enable_workflow_job_labels_check    = var.runner_enable_workflow_job_labels_check
  create_service_linked_role_spot            = var.create_service_linked_role_spot
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

