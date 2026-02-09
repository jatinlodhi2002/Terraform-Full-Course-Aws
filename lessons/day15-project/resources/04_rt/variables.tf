variable "primary_vpc_id" {
    description = "Primary VPC ID"
    type        = string
}

variable "secondary_vpc_id" {
    description = "Secondary VPC ID"
    type        = string
  
}

variable "primary_igw_id" {
    description = "Primary Internet Gateway ID"
    type        = string
}

variable "secondary_igw_id" {
    description = "Secondary Internet Gateway ID"
    type        = string
}