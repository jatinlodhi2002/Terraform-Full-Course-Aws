output "primary_vpc_id" {
  value = aws_vpc.primary_vpc.id
  
}

output "secondary_vpc_id" {
  value = aws_vpc.secondary_vpc.id
  
}

output "primary_vpc_name" {
  value = aws_vpc.primary_vpc.tags["Name"]  
  
}

output "secondary_vpc_name" {
  value = aws_vpc.secondary_vpc.tags["Name"]
}