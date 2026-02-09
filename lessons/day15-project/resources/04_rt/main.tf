# Route table for Primary VPC
resource "aws_route_table" "primary_rt" {
  vpc_id   = var.primary_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.primary_igw_id
  }

  tags = {
    Name        = "Primary-Route-Table"
    Environment = "Demo"
  }
}

# Route table for Secondary VPC
resource "aws_route_table" "secondary_rt" {
  vpc_id   = var.secondary_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.secondary_igw_id
  }

  tags = {
    Name        = "Secondary-Route-Table"
    Environment = "Demo"
  }
}
