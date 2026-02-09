
# Add route to Secondary VPC in Primary route table
resource "aws_route" "primary_to_secondary" {
  route_table_id            = var.primary_rt_id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id

}

# Add route to Primary VPC in Secondary route table
resource "aws_route" "secondary_to_primary" {
  route_table_id            = var.secondary_rt_id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id
}