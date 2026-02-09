variable "primary_vpc_id" {
  description = "ID of the Primary VPC"
  type        = string
  
}

variable "secondary_vpc_id" {
  description = "ID of the Secondary VPC"
  type        = string
  
}

variable "primary_subnet_cidr" {
  description = "CIDR block for the Primary subnet"
  type        = string
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the Secondary subnet"
  type        = string
  
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
  default     = "us-west-2"
}