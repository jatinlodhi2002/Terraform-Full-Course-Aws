output "aws_security_group_id_primary" {
    description = "ID of the Primary Security Group"
    value       = aws_security_group.primary_sg.id
  
}

output "aws_security_group_id_secondary" {
    description = "ID of the Secondary Security Group"
    value       = aws_security_group.secondary_sg.id
  
}   
