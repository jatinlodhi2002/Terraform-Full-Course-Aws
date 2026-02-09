output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.this.public_dns
}

output "private_dns" {
  description = "The private DNS name of the EC2 instance"
  value       = aws_instance.this.private_dns
}

output "availability_zone" {
  description = "The availability zone where the instance is running"
  value       = aws_instance.this.availability_zone
}

output "instance_state" {
  description = "The state of the EC2 instance"
  value       = aws_instance.this.instance_state
}

output "key_name" {
  description = "The key pair name used for the instance"
  value       = aws_instance.this.key_name
}

output "security_groups" {
  description = "The security groups attached to the instance"
  value       = aws_instance.this.vpc_security_group_ids
}

# Primary Instance Outputs
output "primary_instance_id" {
  description = "The ID of the primary EC2 instance"
  value       = aws_instance.primary_instance.id
}

output "primary_instance_arn" {
  description = "The ARN of the primary EC2 instance"
  value       = aws_instance.primary_instance.arn
}

output "primary_public_ip" {
  description = "The public IP address of the primary EC2 instance"
  value       = aws_instance.primary_instance.public_ip
}

output "primary_private_ip" {
  description = "The private IP address of the primary EC2 instance"
  value       = aws_instance.primary_instance.private_ip
}

output "primary_public_dns" {
  description = "The public DNS name of the primary EC2 instance"
  value       = aws_instance.primary_instance.public_dns
}

output "primary_availability_zone" {
  description = "The availability zone where the primary instance is running"
  value       = aws_instance.primary_instance.availability_zone
}

# Secondary Instance Outputs
output "secondary_instance_id" {
  description = "The ID of the secondary EC2 instance"
  value       = aws_instance.secondary_instance.id
}

output "secondary_instance_arn" {
  description = "The ARN of the secondary EC2 instance"
  value       = aws_instance.secondary_instance.arn
}

output "secondary_public_ip" {
  description = "The public IP address of the secondary EC2 instance"
  value       = aws_instance.secondary_instance.public_ip
}

output "secondary_private_ip" {
  description = "The private IP address of the secondary EC2 instance"
  value       = aws_instance.secondary_instance.private_ip
}

output "secondary_public_dns" {
  description = "The public DNS name of the secondary EC2 instance"
  value       = aws_instance.secondary_instance.public_dns
}

output "secondary_availability_zone" {
  description = "The availability zone where the secondary instance is running"
  value       = aws_instance.secondary_instance.availability_zone
}
