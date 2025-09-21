terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# WAF Web ACL for Application Load Balancer
resource "aws_wafv2_web_acl" "main" {
  provider = aws.us-west-2
  
  name  = "${var.cluster_name}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule to block requests from specific countries (example: block all except US)
  rule {
    name     = "GeoBlockingRule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      geo_match_statement {
        country_codes = ["CN", "RU", "KP"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoBlockingRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  # Rule to block requests with suspicious patterns
  rule {
    name     = "SQLInjectionRule"
    priority = 2

    override_action {
      none {}
    }

    statement {
      sqli_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
        text_transformation {
          priority = 1
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  # Rule to block requests with XSS patterns
  rule {
    name     = "XSSRule"
    priority = 3

    override_action {
      none {}
    }

    statement {
      xss_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
        text_transformation {
          priority = 1
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  # Rule to rate limit requests
  rule {
    name     = "RateLimitRule"
    priority = 4

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.cluster_name}-waf"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# WAF Web ACL for C2 cluster
resource "aws_wafv2_web_acl" "c2" {
  provider = aws.us-east-1
  
  name  = "${var.cluster_name}-c2-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Same rules as C1 for consistency
  rule {
    name     = "GeoBlockingRule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      geo_match_statement {
        country_codes = ["CN", "RU", "KP"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoBlockingRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  rule {
    name     = "SQLInjectionRule"
    priority = 2

    override_action {
      none {}
    }

    statement {
      sqli_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
        text_transformation {
          priority = 1
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  rule {
    name     = "XSSRule"
    priority = 3

    override_action {
      none {}
    }

    statement {
      xss_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
        text_transformation {
          priority = 1
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  rule {
    name     = "RateLimitRule"
    priority = 4

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.cluster_name}-c2-waf"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# Network ACL for C1 private subnets
resource "aws_network_acl" "c1_private" {
  provider = aws.us-west-2
  
  vpc_id = var.vpc_c1_id

  # Allow inbound traffic from C2 VPC CIDR
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_c2_cidr
    from_port  = 8080
    to_port    = 8080
  }

  # Allow inbound traffic from C2 VPC CIDR for HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.vpc_c2_cidr
    from_port  = 443
    to_port    = 443
  }

  # Allow inbound traffic from C2 VPC CIDR for HTTP
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.vpc_c2_cidr
    from_port  = 80
    to_port    = 80
  }

  # Allow ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow outbound traffic to C2 VPC CIDR
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_c2_cidr
    from_port  = 0
    to_port    = 65535
  }

  # Allow outbound traffic to internet (for NAT)
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-c1-private-nacl"
  })
}

# Network ACL for C2 private subnets
resource "aws_network_acl" "c2_private" {
  provider = aws.us-east-1
  
  vpc_id = var.vpc_c2_id

  # Allow inbound traffic from C1 VPC CIDR
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_c1_cidr
    from_port  = 8080
    to_port    = 8080
  }

  # Allow inbound traffic from C1 VPC CIDR for HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.vpc_c1_cidr
    from_port  = 443
    to_port    = 443
  }

  # Allow inbound traffic from C1 VPC CIDR for HTTP
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.vpc_c1_cidr
    from_port  = 80
    to_port    = 80
  }

  # Allow ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow outbound traffic to C1 VPC CIDR
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_c1_cidr
    from_port  = 0
    to_port    = 65535
  }

  # Allow outbound traffic to internet (for NAT)
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-c2-private-nacl"
  })
}

# VPC Endpoint for cross-cluster communication (S3 access)
resource "aws_vpc_endpoint" "s3_c1" {
  provider = aws.us-west-2
  
  vpc_id       = var.vpc_c1_id
  service_name = "com.amazonaws.${var.region_c1}.s3"
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-c1-s3-endpoint"
  })
}

resource "aws_vpc_endpoint" "s3_c2" {
  provider = aws.us-east-1
  
  vpc_id       = var.vpc_c2_id
  service_name = "com.amazonaws.${var.region_c2}.s3"
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-c2-s3-endpoint"
  })
}

# VPC Endpoint Policy for least privilege access
resource "aws_vpc_endpoint_policy" "s3_c1" {
  provider = aws.us-west-2
  
  vpc_endpoint_id = aws_vpc_endpoint.s3_c1.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.s3_c1.id
          }
        }
      }
    ]
  })
}

resource "aws_vpc_endpoint_policy" "s3_c2" {
  provider = aws.us-east-1
  
  vpc_endpoint_id = aws_vpc_endpoint.s3_c2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.s3_c2.id
          }
        }
      }
    ]
  })
}
