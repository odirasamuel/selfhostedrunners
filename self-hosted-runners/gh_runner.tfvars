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
  key_base64     = "odi-selfhosted-github-app.2022-12-07.private-key.pem"
  webhook_secret = "OdiWebhookSecret07122022"
  client_id      = "Iv1.20a3a1deb4920291"
  client_secret  = "3e6185fc6116fd655242304ed3a74463848abf40"
}
repository_white_list = [
  # "robot-stack-infra",
  # "opentrons-python-packages",
  # "oe-core"
]
