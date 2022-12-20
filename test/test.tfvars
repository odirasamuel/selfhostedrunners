stack_name         = "test-runners"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
cidr_block = {
  test    = "10.56.0.0/22"
  staging = "10.54.0.0/22"
  prod    = "10.55.0.0/22"
}
public_subnets_count = {
  test    = 3
  staging = 3
  prod    = 3
}
public_subnets_cidr = {
  test    = ["10.56.0.128/25", "10.56.1.128/25", "10.56.2.128/25"]
  staging = ["10.54.0.128/25", "10.54.1.128/25", "10.54.2.128/25"]
  prod    = ["10.55.0.128/25", "10.55.1.128/25", "10.55.2.128/25"]
}
private_subnets_count = {
  test    = 3
  staging = 3
  prod    = 3
}
private_subnets_cidr = {
  test    = ["10.56.0.0/25", "10.56.1.0/25", "10.56.2.0/25"]
  staging = ["10.54.0.0/25", "10.54.1.0/25", "10.54.2.0/25"]
  prod    = ["10.55.0.0/25", "10.55.1.0/25", "10.55.2.0/25"]
}
nat_gateway_count = {
  test    = 1
  staging = 1
  prod    = 1
}
elastic_ips = {
  test    = 1
  staging = 1
  prod    = 1
}