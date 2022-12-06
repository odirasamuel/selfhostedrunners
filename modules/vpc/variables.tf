variable "cidr_block" {
  description = "CIDR block of VPC"
  type        = map(string)
}

variable "public_subnets_cidr" {
  description = "Public Subnets CIDRs"
  type        = map(list(string))
}

variable "private_subnets_cidr" {
  description = "Private Subnets CIDRs"
  type        = map(list(string))
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

variable "private_subnets_count" {
  description = "Number of private subnets to be created"
  type        = map(number)
}

variable "public_subnets_count" {
  description = "Number of public subnets to be created"
  type        = map(number)
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to be created"
  type        = map(number)
}

variable "elastic_ips" {
  description = "Number of required Elastic IPs to allocate to NAT Gateways, must be equal to the number of NAT Gateways"
  type        = map(number)
}

variable "stack_name" {
  description = "Name of Stack"
  type        = string
}


