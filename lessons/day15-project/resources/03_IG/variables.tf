variable "primary_region" {
    description = "Internet Gateway Primary region"
    type        = string
}

variable "secondary_region" {
    description = "Internet Gateway Secondary region"
    type        = string
}

variable "primary_vpc_id" {
    description = "Primary VPC ID"
    type        = string
}

variable "secondary_vpc_id" {
    description = "Secondary VPC ID"
    type        = string
}