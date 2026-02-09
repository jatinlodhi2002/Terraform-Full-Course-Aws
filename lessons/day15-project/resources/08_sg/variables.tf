variable "primary_sg_name" {
    description = "The name of the Primary Security Group"
    type        = string
}

variable "secondary_sg_name" {
    description = "The name of the Secondary Security Group"
    type        = string
}

variable "primary_vpc_id" {
    description = "Primary VPC ID"
    type = string
  
}

variable "secondary_vpc_id" {
    description = "Secondary VPC ID"
    type = string
  
}

variable "secondary_vpc_cidr" {
    description = "CIDR block of the Secondary VPC"
    type = string
}

variable "primary_vpc_cidr" {
    description = "CIDR block of the Primary VPC"
    type = string
}