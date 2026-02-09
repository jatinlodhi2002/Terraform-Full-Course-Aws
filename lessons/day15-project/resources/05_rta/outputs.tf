output "primary_subnet_id" {
  value = aws_route_table_association.primary_rta.subnet_id
}

output "secondary_subnet_id" {
  value = aws_route_table_association.secondary_rta.subnet_id
}

output "primary_route_table_id" {
  value = aws_route_table_association.primary_rta.route_table_id
}

output "secondary_route_table_id" {
  value = aws_route_table_association.secondary_rta.route_table_id  
}