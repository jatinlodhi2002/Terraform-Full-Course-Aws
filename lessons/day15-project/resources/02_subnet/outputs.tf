output "primary_subnet_id" {
  value = aws_subnet.primary_subnet.id
}

output "secondary_subnet_id" {
  value = aws_subnet.secondary_subnet.id
}