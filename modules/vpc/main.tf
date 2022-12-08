data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  vpc_name              = "${var.stack_name}-${terraform.workspace}-vpc"
  private_subnet_name   = "${var.stack_name}-${terraform.workspace}-private-subnet"
  public_subnet_name    = "${var.stack_name}-${terraform.workspace}-public-subnet"
  cidr_block            = var.cidr_block[terraform.workspace]
  public_subnets_count  = var.public_subnets_count[terraform.workspace]
  private_subnets_count = var.private_subnets_count[terraform.workspace]
  public_subnets_cidr   = var.public_subnets_cidr[terraform.workspace]
  private_subnets_cidr  = var.private_subnets_cidr[terraform.workspace]
  nat_gateway_count     = var.nat_gateway_count[terraform.workspace]
}

#VPC
resource "aws_vpc" "vpc" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name        = local.vpc_name
    Environment = terraform.workspace
  }
}

#Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = local.private_subnets_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(local.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.public_subnet_name}-${count.index + 1}"
    Environment = terraform.workspace
  }
}

#Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = local.private_subnets_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(local.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${local.private_subnet_name}-${count.index + 1}"
    Environment = terraform.workspace
  }
}

#Internet Gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.vpc_name}-igw"
    Environment = terraform.workspace
  }
}

#Route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = {
    Name        = "${local.vpc_name}-public-rt"
    Environment = terraform.workspace
  }
}

#Associate Route table with the public subnets
resource "aws_route_table_association" "public_rta" {
  count          = local.public_subnets_count
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# #NAT Gateway
#Elastic ip for NAT Gateways
resource "aws_eip" "elastic_ips" {
  count = var.elastic_ips[terraform.workspace]
  vpc   = true

  tags = {
    Name        = "${local.vpc_name}-elastic-ip-${count.index + 1}"
    Environment = terraform.workspace
  }
}

#Allocate each NAT gateway to each public subnet
resource "aws_nat_gateway" "nat_gateway" {
  count         = local.nat_gateway_count
  allocation_id = element(aws_eip.elastic_ips[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name        = "${local.vpc_name}-nat-gateway-${count.index + 1}"
    Environment = terraform.workspace
  }

  depends_on = [aws_internet_gateway.vpc_igw]
}

#Route table for private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway[*].id, 0)
  }

  tags = {
    Name        = "${local.vpc_name}-private-rt"
    Environment = terraform.workspace
  }
}

#Associate Route table with the private subnets
resource "aws_route_table_association" "private_rta" {
  count          = local.private_subnets_count
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}






output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "public_subnets_id" {
  value = [aws_subnet.public_subnets[*].id]
}

output "private_subnets_id" {
  value = [aws_subnet.private_subnets[*].id]
}

output "private_subnets_1_id" {
  value = aws_subnet.private_subnets[0].id
}

output "private_subnets_2_id" {
  value = aws_subnet.private_subnets[1].id
}

output "private_subnets_3_id" {
  value = aws_subnet.private_subnets[2].id
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}
