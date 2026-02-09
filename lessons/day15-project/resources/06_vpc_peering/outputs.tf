output "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection"
  value       = aws_vpc_peering_connection.primary_to_secondary.id
  
}

output "name" {
  description = "The name of the VPC Peering Connection"
  value       = aws_vpc_peering_connection.primary_to_secondary.tags["Name"]
}