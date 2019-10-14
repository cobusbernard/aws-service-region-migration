# Peer with the source vpc
## Request from the environment vpc to the source one.
resource "aws_vpc_peering_connection" "source_vpc" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = module.vpc_new.vpc_id
  peer_region = "eu-central-1"
  auto_accept = false
}

# source accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "source_vpc" {
  provider                  = "aws.new"
  vpc_peering_connection_id = aws_vpc_peering_connection.source_vpc.id
  auto_accept               = true
}

## From destination to source
resource "aws_route" "public_to_source_vpc" {
  provider                  = "aws.new"
  count                     = "${length(module.vpc.public_route_table_ids)}"
  route_table_id            = "${element(module.vpc_new.public_route_table_ids, count.index)}"
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source_vpc.id
}

resource "aws_route" "nat_to_source_vpc" {
  provider                  = "aws.new"
  count                     = "${length(module.vpc.azs)}"
  route_table_id            = "${element(module.vpc_new.private_route_table_ids, count.index)}"
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source_vpc.id
}

## From source to destination
resource "aws_route" "source_vpc_to_public" {
  count                     = "${length(module.vpc_new.public_route_table_ids)}"
  route_table_id            = "${element(module.vpc.public_route_table_ids, count.index)}"
  destination_cidr_block    = module.vpc_new.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source_vpc.id
}

resource "aws_route" "source_vpc_to_nat" {
  count                     = "${length(module.vpc_new.private_route_table_ids)}"
  route_table_id            = "${element(module.vpc.private_route_table_ids, count.index)}"
  destination_cidr_block    = module.vpc_new.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source_vpc.id
}