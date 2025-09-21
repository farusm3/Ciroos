terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Transit Gateway in us-west-2
resource "aws_ec2_transit_gateway" "main" {
  provider = aws.us-west-2

  description                     = "Transit Gateway for cross-region connectivity"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, {
    Name = "petclinic-tgw"
  })
}

# Transit Gateway VPC Attachment for C1 cluster
resource "aws_ec2_transit_gateway_vpc_attachment" "c1" {
  provider = aws.us-west-2

  subnet_ids                                      = var.vpc_c1_private_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = var.vpc_c1_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, {
    Name = "tgw-attachment-c1"
  })
}

# Transit Gateway VPC Attachment for C2 cluster (cross-region)
resource "aws_ec2_transit_gateway_vpc_attachment" "c2" {
  provider = aws.us-east-1

  subnet_ids                                      = var.vpc_c2_private_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = var.vpc_c2_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, {
    Name = "tgw-attachment-c2"
  })
}

# Custom route table for cross-cluster communication
resource "aws_ec2_transit_gateway_route_table" "cross_cluster" {
  provider = aws.us-west-2

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(var.tags, {
    Name = "tgw-route-table-cross-cluster"
  })
}

# Route table associations
resource "aws_ec2_transit_gateway_route_table_association" "c1" {
  provider = aws.us-west-2

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cross_cluster.id
}

resource "aws_ec2_transit_gateway_route_table_association" "c2" {
  provider = aws.us-east-1

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cross_cluster.id
}

# Route table propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "c1" {
  provider = aws.us-west-2

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cross_cluster.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "c2" {
  provider = aws.us-east-1

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cross_cluster.id
}

# Routes for cross-cluster communication
resource "aws_ec2_transit_gateway_route" "c1_to_c2" {
  provider = aws.us-west-2

  destination_cidr_block         = var.vpc_c2_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cross_cluster.id
}

resource "aws_ec2_transit_gateway_route" "c2_to_c1" {
  provider = aws.us-east-1

  destination_cidr_block         = var.vpc_c1_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cross_cluster.id
}
