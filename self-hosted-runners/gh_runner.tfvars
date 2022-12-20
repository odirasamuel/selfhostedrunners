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
  key_base64     = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBeDhVL29YUVp6M0psWTBaYy9Cc2tUaWwrUmZLenRtbkM3MVovc2w3WUxDOTBRV1p3CkZ3ckNLaVRhY2FjYlhlRmlVYUhkMysyTUNJMEdvWkNMeUExOWpLblB2OUh6aXVxblQ3TnpXNFhqZnF0Ymg3WHkKYjg1Ly9JVkR0TWNhSEYrUE5xcklaT1JTc2ZBUUE2RTBsRGUvMElzdkhHdEdpNHNwOGswQXBWUTRPcDA2ek53YQpaYVZUazByV1hPZHplT1RUMlZadUdZT1BneEtTMVNveDZLVkdsM1hHbkpWUmNOZGptK2txOWtVY3Z3cXAxWmlJCm9wV2tTd09HMTQ4N0xENmVnZUhqYmxJSEU5dm9mNHcrNlRCdmgwZk1mL1BseEt2U1BLQW5TanNxdktSM09kUXoKWUxUYi9jSmxBK3d3WTZ4b21WRytSaDdFYkZLRG9WK2xoaHlWc3dJREFRQUJBb0lCQUhuM0IxNC9UL0xEV1BzLwpYazNkRkZGVUsrL3d1Wi9JK21hOVhNRTkvcVViWTlMNkE3MU5xRFdxd21OWkx2QW1ScXlvTXBvZ29ib212OEdzClNtc2RNV1hMMXphNXJBTklPRllFclkxWE5RbUUvU0RpQ040U0tUbTI4eHRQNDdVbThuemh6KzhwSndQVUdUTGUKSFFmUThaOFZHdkl5M0tNZGw4S0RHTDNYcVd5K3MvVUh1NjRBM2EzbUlpZGE3a21saVpMYWtQRGN5c01idnp0WgpYWHFYZHNvVGFST0lsalVZUk03OEVFNERlVDRoUFpiT0c2aWRWMS9GVEZpTEJhbytmRnNCcVNXRmI4dEVoWGJmCkRhMWlza2ErVk42M3ZYSTBtUzIrVWlIZUpacnA5TkM0cVBWOHlDcnBndmVwSDRGaE14aGl3dlFpSHJiNEF1eDkKcnNWUFpZRUNnWUVBL0dtTi80V1ZLTzBqNUhCMzJvT2cvVFpzb1l0TXAxT2JYWjVCcUhKVWxPV0M1ZjF5V3dCagpZbzZEOXN0VVpqdDZ6NjZpVVAzMjBtNXBWR1A4VUpNQXFtZFhKREV6dDYrNlF0MUtydFVJQ1lqV1MzaXliTEpyCmcwWnRoVUg4NzJ6VEFMdjJDSGp2NHRXOHh6L3E5VGFkR3dlZm1NM3VxdjUxaFBMYzNHZmE4Z01DZ1lFQXlwd2wKeXVOY2J3b2tmT0ZmZzljNGdZb1dmQXUxU01WL1ZNMGJHaUxHblYxdHh2V1RxUHh6OE5UaHhDTUludlZ1anUraQpGR0tQYWN2VnhuYzJTSjNmaldyd3JpWDNac0Nldk5NSUlVLzI5TW8wbjFLc0pBUDdzd25PQVRWMmd6Z3NlSXdxCkhXZUtidHQ5ZW9zSkpQOCt1UGhQS05SREh5NHluVm5TYndPWjFwRUNnWUVBcFV6Zk1IS2ovMXhsd0FtamhCZmwKeTAza0VGc3doUGdzN0Q5aTBsU2xiYWxzY3YvcTd3dXZDbkU0bk53RjFybW5NUEUxM1lLa0xLVWdGNk12THZsRwpXMUkzOER6RW1NdmRXRUtoMFNNMEUwSm96SjRyZ3lISlpQd3ZaekNTMjUxU0JjNFNUdlFjYlZuNk9pWnkwY25GClUxbEh2SU5JaFBVRnMxNTFJMlprTFU4Q2dZRUFvNWhETjdndmFZVkNBd2VqTFB3NXB2Y053cWxkZmwzaHUySkYKY093RmZRajBXOExzc0hUdlZOVS9XalNEZ0g1aC84M2tEQnVzK3RyWVNRRDI5dGxxcVhCZzErelYvOFNtSjRjcQpPR090M3VmcVozN0VlZXd4YnRZSzNaVUNsVjlsSVF6ajhJd3JEZW55UG1GSFIvVkUrdXVjVnpaVTREZFlMUTlhCng4S2JrOUVDZ1lFQXZHNGpxU2ZHaitLVFNDSVlIamM3aVYvSEQ3dFVSQzM1VDJyck9JSi9oOU5EVVQ3TnpKeVIKTFI2L3JkeEY4ZmQ2VlpxODllZWVaZUhoM05iRXJQMC9Xbk50RE1Cbm15dzM3OVRXV0pMdlpOMVcxQUtJSEhCQgpoaGZpK29OZzhwOUZvRUNGZlhyT0E4MEpvb2ZvcHV1d0w3UzFaZzg5SDc0bVVVTng5NjNoL3BZPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
  webhook_secret = "OdiWebhookSecret07122022"
  client_id      = "Iv1.20a3a1deb4920291"
  client_secret  = "3e6185fc6116fd655242304ed3a74463848abf40"
}
repository_white_list = [
  # "robot-stack-infra",
  # "opentrons-python-packages",
  # "oe-core"
]
