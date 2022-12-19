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
    key_base64     = "MIIEogIBAAKCAQEAtsIVbCUhNgivUZR5Jb6tng8SL2wThhnF88Vb3+nANhgNh8Gy3vVyfHpiA2Zyqxq+wBTkfoeQVuDgQwF53Dc6CcwEQENRKfWyG7FmrcgaV/AkE/Vo1gyrQ3ng7870dnMbYd2yt108CEWhYmfvic3RKctihAYt+omfpxTo9CTzVh0htdkSxbBWnnS7hsHLUMaJrK5wDr7VghDBL6578RrBzA6c1vmM+uHCwKJznvz/N7PzBI9P4mwGehXRMwBBHyhxhhqQLPKp+YrwmByaSl8jsYcoQpjc43uslsoC/QFYTH6H7CFr8sOxBp1UAsTdgpc9+s28pZDYZ2XU5qTNLjWF8wIDAQABAoIBACgKuBTcwb0MBBWUuUJq17FUzgAz5scv6G4zpKCXn3R6qqQ+7UjqcC4TxlvGW4NftcFyEmoim55dYOVtclysgPvahmfqF+NgoKhuoveaayMvS0hQMasMVY3QK1d/eZJmP+6eW2TPebK6RtS/vvzralOE603P6M0G0EMUUsIDQolwM4fUOmUARBo+uvxBbbWZvWQ2x//46fQMdWhtMuMXtcV9Zhpd4L+2C3StWD2NMnxMBHI6zno/G19oa2VWc1f2iUOqEDHd1iMNazt7wwca+Y4ylldtpB7O37DV5RnRdU8/TQP5gT66+1yohGDeMG9fzOM7q+MegzYs7oik/YoGgCECgYEA6DhLl2bmUrE4rmMAGoZvCYkIiI2HOe5SRz2YAzgX5XkqAQ8oQDOs8BGmj/3n6G/iIUY4Q3uJlcSwMi519ReRgUat21bxTX2UtTppJfuMreONKTUan6GLUzjzV5tntAS5Lgw1GRNg7HFOox0RLml+8KJBU/pqbTcrKyt6J4+mr3ECgYEAyXkir1qtQY0EVUGhPkb0jWL9YpjuQy8TpykvWsiMCS1FkT+AO0KQ0LWjNiQ9OGoIU2NkY7CBh/c0r3EwqSiXpcY8+13t9riNF4hLIWPFReoAHqUEqB0kD4/EDr6sScCVgy2zJMgZAnRl5zI2PKoXGlsNZW1wORPzVhHAHj86YaMCgYB8QgNQ1GLSRLpLtfXMO7sWoxjJ2NFPElM8g5zfvBgtVhQ/1Nh44i3bl9ZEnlyFZ7jcjTJ2CZipZ0HQ2EOODjpxrlxBTdh42oXEI6k4Bc5VDbnvHtdMK6jds0+ixSlMjmp4VVfkPxZR7p9hcKBM8W5XXLsQMKLaJfcXdoA6wwcyQQKBgE+q6e9DQP2JwKvh3tvcfPmnqiCh7p18cR4JqCMS6GT8lOTBonhMcy1Elfxjyh2TuCUZSWouMppMQ3YYoTBSz9yKjjSryNxlz8z9ZRAX/rsNs+xqPnQnycmphNJ7zW8Ai16q5Irn4RPaaS1J6q6EZ8xRMvPnmZfIbtGbBUgwompXAoGAOCd3D3v1YUNdtrKFopyfIjR8k4oFRJ372S/DpsiehsCZW2em5wiIZTJ6OVni+e6Scpi3mLUnHyg+rCWSGN115d6/J7eF7SciHhD/NFhRtULMb0pRzA9fPwRmMQFwRewgxIwYE2nATLkx0DigkPyJMOI2i1tNISinEKfPOP8RtAc="
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

