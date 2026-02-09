variable "primary_vpc_cidr" {
  description = "CIDR block for the primary VPC in us-east-1"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  description = "CIDR block for the secondary VPC in us-west-2"
  type        = string
  default     = "10.1.0.0/16"
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