output "waf_web_acl_c1_arn" {
  description = "ARN of the WAF Web ACL for C1"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_c2_arn" {
  description = "ARN of the WAF Web ACL for C2"
  value       = aws_wafv2_web_acl.c2.arn
}

output "network_acl_c1_id" {
  description = "ID of the Network ACL for C1 private subnets"
  value       = aws_network_acl.c1_private.id
}

output "network_acl_c2_id" {
  description = "ID of the Network ACL for C2 private subnets"
  value       = aws_network_acl.c2_private.id
}

output "vpc_endpoint_c1_id" {
  description = "ID of the VPC Endpoint for C1"
  value       = aws_vpc_endpoint.s3_c1.id
}

output "vpc_endpoint_c2_id" {
  description = "ID of the VPC Endpoint for C2"
  value       = aws_vpc_endpoint.s3_c2.id
}
