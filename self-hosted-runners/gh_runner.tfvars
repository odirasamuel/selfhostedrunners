stack_name               = "odira-runners"
distribution_bucket_name = "odira-dist"
availability_zones       = ["us-east-1a", "us-east-1b", "us-east-1c"]
cidr_block = {
  dev     = "10.53.0.0/22"
  staging = "10.54.0.0/22"
  prod    = "10.55.0.0/22"
}
public_subnets_count = {
  dev     = 3
  staging = 3
  prod    = 3
}
public_subnets_cidr = {
  dev     = ["10.53.0.128/25", "10.53.1.128/25", "10.53.2.128/25"]
  staging = ["10.54.0.128/25", "10.54.1.128/25", "10.54.2.128/25"]
  prod    = ["10.55.0.128/25", "10.55.1.128/25", "10.55.2.128/25"]
}
private_subnets_count = {
  dev     = 3
  staging = 3
  prod    = 3
}
private_subnets_cidr = {
  dev     = ["10.53.0.0/25", "10.53.1.0/25", "10.53.2.0/25"]
  staging = ["10.54.0.0/25", "10.54.1.0/25", "10.54.2.0/25"]
  prod    = ["10.55.0.0/25", "10.55.1.0/25", "10.55.2.0/25"]
}
nat_gateway_count = {
  dev     = 1
  staging = 1
  prod    = 1
}
elastic_ips = {
  dev     = 1
  staging = 1
  prod    = 1
}
pool_config = [
  {
    schedule_expression = "cron(*/59 * 8-23 * ? 1-5)"
    size                = 3
  },
  {
    schedule_expression = "cron(*/59 * 1-23 * ? 6-7)"
    size                = 1
  }
]
instance_allocation_strategy = "capacity-optimized"
instance_max_spot_price      = "1"
ami_filter = {
  "name"         = ["amzn2-ami-kernel-5.10-hvm-2.0.20221103.3-x86_64-gp2"]
  "architecture" = ["x86_64"]
  # "kernel-id"                        = ["kernel-5.*"]
  # "virtualization-type"              = ["hvm-*"]
  # "block-device-mapping.volume-type" = ["gp2"]
}
# ami_owners                      = ["self"]
minimum_running_time_in_minutes = 10
idle_config = [
  {
    cron      = "*/59 * * * * *"
    idleCount = 1
    timeZone  = "America/New_York"
  }
]
github_app = {
  id             = "269936"
  key_base64     = "MIIEpQIBAAKCAQEAx8U/oXQZz3JlY0Zc/BskTil+RfKztmnC71Z/sl7YLC90QWZwFwrCKiTacacbXeFiUaHd3+2MCI0GoZCLyA19jKnPv9HziuqnT7NzW4Xjfqtbh7Xyb85//IVDtMcaHF+PNqrIZORSsfAQA6E0lDe/0IsvHGtGi4sp8k0ApVQ4Op06zNwaZaVTk0rWXOdzeOTT2VZuGYOPgxKS1Sox6KVGl3XGnJVRcNdjm+kq9kUcvwqp1ZiIopWkSwOG1487LD6egeHjblIHE9vof4w+6TBvh0fMf/PlxKvSPKAnSjsqvKR3OdQzYLTb/cJlA+wwY6xomVG+Rh7EbFKDoV+lhhyVswIDAQABAoIBAHn3B14/T/LDWPs/Xk3dFFFUK+/wuZ/I+ma9XME9/qUbY9L6A71NqDWqwmNZLvAmRqyoMpogobomv8GsSmsdMWXL1za5rANIOFYErY1XNQmE/SDiCN4SKTm28xtP47Um8nzhz+8pJwPUGTLeHQfQ8Z8VGvIy3KMdl8KDGL3XqWy+s/UHu64A3a3mIida7kmliZLakPDcysMbvztZXXqXdsoTaROIljUYRM78EE4DeT4hPZbOG6idV1/FTFiLBao+fFsBqSWFb8tEhXbfDa1iska+VN63vXI0mS2+UiHeJZrp9NC4qPV8yCrpgvepH4FhMxhiwvQiHrb4Aux9rsVPZYECgYEA/GmN/4WVKO0j5HB32oOg/TZsoYtMp1ObXZ5BqHJUlOWC5f1yWwBjYo6D9stUZjt6z66iUP320m5pVGP8UJMAqmdXJDEzt6+6Qt1KrtUICYjWS3iybLJrg0ZthUH872zTALv2CHjv4tW8xz/q9TadGwefmM3uqv51hPLc3Gfa8gMCgYEAypwlyuNcbwokfOFfg9c4gYoWfAu1SMV/VM0bGiLGnV1txvWTqPxz8NThxCMInvVuju+iFGKPacvVxnc2SJ3fjWrwriX3ZsCevNMIIU/29Mo0n1KsJAP7swnOATV2gzgseIwqHWeKbtt9eosJJP8+uPhPKNRDHy4ynVnSbwOZ1pECgYEApUzfMHKj/1xlwAmjhBfly03kEFswhPgs7D9i0lSlbalscv/q7wuvCnE4nNwF1rmnMPE13YKkLKUgF6MvLvlGW1I38DzEmMvdWEKh0SM0E0JozJ4rgyHJZPwvZzCS251SBc4STvQcbVn6OiZy0cnFU1lHvINIhPUFs151I2ZkLU8CgYEAo5hDN7gvaYVCAwejLPw5pvcNwqldfl3hu2JFcOwFfQj0W8LssHTvVNU/WjSDgH5h/83kDBus+trYSQD29tlqqXBg1+zV/8SmJ4cqOGOt3ufqZ37EeewxbtYK3ZUClV9lIQzj8IwrDenyPmFHR/VE+uucVzZU4DdYLQ9ax8Kbk9ECgYEAvG4jqSfGj+KTSCIYHjc7iV/HD7tURC35T2rrOIJ/h9NDUT7NzJyRLR6/rdxF8fd6VZq89eeeZeHh3NbErP0/WnNtDMBnmyw379TWWJLvZN1W1AKIHHBBhhfi+oNg8p9FoECFfXrOA80JoofopuuwL7S1Zg89H74mUUNx963h/pY="
  webhook_secret = "OdiWebhookSecret07122022"
  client_id      = "Iv1.20a3a1deb4920291"
  client_secret  = "3e6185fc6116fd655242304ed3a74463848abf40"
}
repository_white_list = [
  # "robot-stack-infra",
  # "opentrons-python-packages",
  # "oe-core"
]
