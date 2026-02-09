variable "primary_vpc_id" {
  description = "The ID of the Primary VPC (Requester side)"
  type        = string
}

variable "secondary_vpc_id" {
  description = "The ID of the Secondary VPC (Accepter side)"
  type        = string
}

variable "secondary_region" {
  description = "The AWS region where the Secondary VPC is located"
  type        = string
  default     = "us-west-2"
}