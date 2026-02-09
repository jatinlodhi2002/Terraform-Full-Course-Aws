# EC2 Instance in Primary VPC
resource "aws_instance" "primary_instance" {
  ami                    = var.primary_ami
  instance_type          = var.instance_type
  subnet_id              = var.primary_subnet_id
  vpc_security_group_ids = [var.primary_sg_id]
  key_name               = var.primary_key_name

  user_data = var.primary_user_data

  tags = {
    Name        = "Primary-VPC-Instance"
    Environment = "Demo"
    Region      = var.primary_region
  }
}

# EC2 Instance in Secondary VPC
resource "aws_instance" "secondary_instance" {
  ami                    = var.secondary_ami
  instance_type          = var.instance_type
  subnet_id              = var.secondary_subnet_id
  vpc_security_group_ids = [var.secondary_sg_id]
  key_name               = var.secondary_key_name

  user_data = var.secondary_user_data

  tags = {
    Name        = "Secondary-VPC-Instance"
    Environment = "Demo"
    Region      = var.secondary_region
  }
}
