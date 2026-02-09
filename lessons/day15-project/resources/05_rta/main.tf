# Associate route table with Primary subnet
resource "aws_route_table_association" "primary_rta" {
  subnet_id      =var.primary_subnet_id
  route_table_id = var.primary_route_table_id
}
# Associate route table with Secondary subnet
resource "aws_route_table_association" "secondary_rta" {
  subnet_id      = var.secondary_subnet_id
  route_table_id = var.secondary_route_table_id
}

