resource "aws_vpc" "primary_vpc" {
  cidr_block           = var.primary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "primary-vpc-${var.primary_region}"
    Environment = "Demo"
    Purpose     = "VPC-Peering-Demo"
  }
}

# Secondary VPC in us-west-2
resource "aws_vpc" "secondary_vpc" {
  cidr_block           = var.secondary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "Secondary-VPC-${var.secondary_region}"
    Environment = "Demo"
    Purpose     = "VPC-Peering-Demo"
  }
}