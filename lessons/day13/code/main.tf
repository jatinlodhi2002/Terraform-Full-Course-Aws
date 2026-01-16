provider "aws" {
  region = "ap-south-1"
  profile = "learn-tf"
}

# Data source to get the existing VPC
data "aws_vpc" "shared" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

# Data source to get the existing subnet
data "aws_subnet" "shared" {
  filter {
    name   = "tag:Name"
    values = ["default-subnet-a"]
  }
  vpc_id = data.aws_vpc.shared.id
}

# Data source for the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.shared.id
  # private_ip is automatically assigned by AWS from the subnet range

  tags = {
    Name = "day13-instance"
  }
}
