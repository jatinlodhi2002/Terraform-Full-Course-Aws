# VPC Peering Connection (Requester side - Primary VPC)
resource "aws_vpc_peering_connection" "primary_to_secondary" {
  vpc_id      = var.primary_vpc_id
  peer_vpc_id = var.secondary_vpc_id
  peer_region = var.secondary_region
  auto_accept = false

  tags = {
    Name        = "Primary-to-Secondary-Peering"
    Environment = "Demo"
    Side        = "Requester"
  }
}

# VPC Peering Connection Accepter (Accepter side - Secondary VPC)
resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true

  tags = {
    Name        = "Secondary-Peering-Accepter"
    Environment = "Demo"
    Side        = "Accepter"
  }
}
