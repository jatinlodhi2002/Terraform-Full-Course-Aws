# Subnet in Primary VPC
resource "aws_subnet" "primary_subnet" {
  vpc_id     = var.primary_vpc_id
  cidr_block =  var.primary_subnet_cidr
  map_public_ip_on_launch = true # Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.

  tags = {
    Name        = "Primary-Subnet-${var.primary_region}"
    Environment = "Demo"
  }
}

# Subnet in Secondary VPC
resource "aws_subnet" "secondary_subnet" {
  vpc_id                  = var.secondary_vpc_id
  cidr_block              = var.secondary_subnet_cidr
  availability_zone       = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true # Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.

  tags = {
    Name        = "Secondary-Subnet-${var.secondary_region}"
    Environment = "Demo"
  }
}