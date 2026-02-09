# Internet Gateway for Primary VPC
resource "aws_internet_gateway" "primary_igw" {
  vpc_id   = var.primary_vpc_id

  tags = {
    Name        = "Primary-IGW"
    Environment = "Demo"
  }
}

# Internet Gateway for Secondary VPC
resource "aws_internet_gateway" "secondary_igw" {
  vpc_id   = var.secondary_vpc_id

  tags = {
    Name        = "Secondary-IGW"
    Environment = "Demo"
  }
}
