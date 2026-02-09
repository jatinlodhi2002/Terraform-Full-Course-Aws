variable "primary_ami" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "secondary_ami" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "primary_subnet_id" {
  description = "The subnet ID for the primary VPC instance"
  type        = string
}

variable "primary_sg_id" {
  description = "Security group ID for the primary VPC instance"
  type        = string
}

variable "primary_key_name" {
  description = "The key pair name for the primary VPC instance"
  type        = string
}

variable "primary_region" {
  description = "The region for the primary VPC"
  type        = string
}

variable "primary_user_data" {
  description = "User data script for the primary instance"
  type        = string
  default     = ""
}

variable "primary_instance_name" {
  description = "Name tag for the primary EC2 instance"
  type        = string
  default     = "Primary-VPC-Instance"
}

variable "secondary_subnet_id" {
  description = "The subnet ID for the secondary VPC instance"
  type        = string
}

variable "secondary_sg_id" {
  description = "Security group ID for the secondary VPC instance"
  type        = string
}

variable "secondary_key_name" {
  description = "The key pair name for the secondary VPC instance"
  type        = string
}

variable "secondary_region" {
  description = "The region for the secondary VPC"
  type        = string
}

variable "secondary_user_data" {
  description = "User data script for the secondary instance"
  type        = string
  default     = ""
}

variable "secondary_instance_name" {
  description = "Name tag for the secondary EC2 instance"
  type        = string
  default     = "Secondary-VPC-Instance"
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Type of root volume (gp2, gp3, io1, etc.)"
  type        = string
  default     = "gp3"
}

variable "tags" {
  description = "Additional tags to apply to the EC2 instance"
  type        = map(string)
  default     = {}
}