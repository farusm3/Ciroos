terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration for us-west-2 (C1 cluster)
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

# Provider configuration for us-east-1 (C2 cluster)
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# Data sources
data "aws_availability_zones" "us_west_2" {
  provider = aws.us-west-2
  state    = "available"
}

data "aws_availability_zones" "us_east_1" {
  provider = aws.us-east-1
  state    = "available"
}

# Local variables
locals {
  cluster_c1_name = "petclinic-c1"
  cluster_c2_name = "petclinic-c2"
  environment     = "production"
  
  # VPC CIDR blocks - ensuring no overlap
  vpc_c1_cidr = "10.0.0.0/16"
  vpc_c2_cidr = "10.1.0.0/16"
  
  # Private subnet CIDRs for C1
  private_subnets_c1 = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  
  # Private subnet CIDRs for C2
  private_subnets_c2 = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24"
  ]
  
  # Public subnet CIDRs for C1 (for NAT Gateways)
  public_subnets_c1 = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
  
  # Public subnet CIDRs for C2 (for NAT Gateways)
  public_subnets_c2 = [
    "10.1.101.0/24",
    "10.1.102.0/24",
    "10.1.103.0/24"
  ]
  
  common_tags = {
    Environment = local.environment
    Project     = "petclinic-microservices"
    ManagedBy   = "terraform"
  }
}

# Module for C1 cluster in us-west-2
module "cluster_c1" {
  source = "./modules/eks-cluster"
  
  providers = {
    aws = aws.us-west-2
  }
  
  cluster_name         = local.cluster_c1_name
  vpc_cidr            = local.vpc_c1_cidr
  private_subnets     = local.private_subnets_c1
  public_subnets      = local.public_subnets_c1
  availability_zones  = data.aws_availability_zones.us_west_2.names
  region              = "us-west-2"
  
  tags = merge(local.common_tags, {
    Cluster = "C1"
    Region  = "us-west-2"
  })
}

# Module for C2 cluster in us-east-1
module "cluster_c2" {
  source = "./modules/eks-cluster"
  
  providers = {
    aws = aws.us-east-1
  }
  
  cluster_name         = local.cluster_c2_name
  vpc_cidr            = local.vpc_c2_cidr
  private_subnets     = local.private_subnets_c2
  public_subnets      = local.public_subnets_c2
  availability_zones  = data.aws_availability_zones.us_east_1.names
  region              = "us-east-1"
  
  tags = merge(local.common_tags, {
    Cluster = "C2"
    Region  = "us-east-1"
  })
}

# Transit Gateway for cross-region connectivity
module "transit_gateway" {
  source = "./modules/transit-gateway"
  
  providers = {
    aws.us-west-2 = aws.us-west-2
    aws.us-east-1 = aws.us-east-1
  }
  
  vpc_c1_id                = module.cluster_c1.vpc_id
  vpc_c2_id                = module.cluster_c2.vpc_id
  vpc_c1_private_subnets   = module.cluster_c1.private_subnets
  vpc_c2_private_subnets   = module.cluster_c2.private_subnets
  vpc_c1_cidr              = local.vpc_c1_cidr
  vpc_c2_cidr              = local.vpc_c2_cidr
  
  tags = local.common_tags
}

# Security Controls (WAF, NACLs, VPC Endpoints)
module "security_controls" {
  source = "./modules/security-controls"
  
  providers = {
    aws.us-west-2 = aws.us-west-2
    aws.us-east-1 = aws.us-east-1
  }
  
  cluster_name = local.cluster_c1_name
  vpc_c1_id    = module.cluster_c1.vpc_id
  vpc_c2_id    = module.cluster_c2.vpc_id
  vpc_c1_cidr  = local.vpc_c1_cidr
  vpc_c2_cidr  = local.vpc_c2_cidr
  region_c1    = "us-west-2"
  region_c2    = "us-east-1"
  
  tags = local.common_tags
}

# Output values
output "cluster_c1_endpoint" {
  description = "Endpoint for C1 EKS cluster"
  value       = module.cluster_c1.cluster_endpoint
}

output "cluster_c2_endpoint" {
  description = "Endpoint for C2 EKS cluster"
  value       = module.cluster_c2.cluster_endpoint
}

output "cluster_c1_kubeconfig" {
  description = "Kubeconfig for C1 cluster"
  value       = module.cluster_c1.kubeconfig
  sensitive   = true
}

output "cluster_c2_kubeconfig" {
  description = "Kubeconfig for C2 cluster"
  value       = module.cluster_c2.kubeconfig
  sensitive   = true
}

output "vpc_c1_id" {
  description = "VPC ID for C1 cluster"
  value       = module.cluster_c1.vpc_id
}

output "vpc_c2_id" {
  description = "VPC ID for C2 cluster"
  value       = module.cluster_c2.vpc_id
}
