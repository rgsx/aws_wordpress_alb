resource "aws_vpc" "vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_public_a" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.cidr_subnet_public_a
  availability_zone       = var.availability_zone_a
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_private_a" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  cidr_block              = var.cidr_subnet_private_a
  availability_zone       = var.availability_zone_a
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_public_b" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.cidr_subnet_public_b
  availability_zone       = var.availability_zone_b
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_private_b" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  cidr_block              = var.cidr_subnet_private_b
  availability_zone       = var.availability_zone_b
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_route_table" "rtbl" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.rtbl.id
}
resource "aws_route_table_association" "rtb" {
  subnet_id      = aws_subnet.subnet_public_b.id
  route_table_id = aws_route_table.rtbl.id
}