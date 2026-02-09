variable "primary_rt_id" {
  description = "The ID of the Primary Route Table"
  type        = string
}

variable "secondary_rt_id" {
  description = "The ID of the Secondary Route Table"
  type        = string
}

variable "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection"
  type        = string
}

variable "primary_vpc_cidr" {
  description = "The CIDR block of the Primary VPC"
  type        = string
}

variable "secondary_vpc_cidr" {
  description = "The CIDR block of the Secondary VPC"
  type        = string
}
