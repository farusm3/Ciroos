output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.arn
}

output "tgw_attachment_c1_id" {
  description = "ID of the Transit Gateway VPC Attachment for C1"
  value       = aws_ec2_transit_gateway_vpc_attachment.c1.id
}

output "tgw_attachment_c2_id" {
  description = "ID of the Transit Gateway VPC Attachment for C2"
  value       = aws_ec2_transit_gateway_vpc_attachment.c2.id
}

output "tgw_route_table_id" {
  description = "ID of the Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.cross_cluster.id
}
