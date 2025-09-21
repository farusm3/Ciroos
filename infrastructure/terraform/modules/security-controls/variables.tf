variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "vpc_c1_id" {
  description = "VPC ID for C1 cluster"
  type        = string
}

variable "vpc_c2_id" {
  description = "VPC ID for C2 cluster"
  type        = string
}

variable "vpc_c1_cidr" {
  description = "CIDR block for C1 VPC"
  type        = string
}

variable "vpc_c2_cidr" {
  description = "CIDR block for C2 VPC"
  type        = string
}

variable "region_c1" {
  description = "AWS region for C1 cluster"
  type        = string
}

variable "region_c2" {
  description = "AWS region for C2 cluster"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for VPC endpoint policy"
  type        = string
  default     = "petclinic-cross-cluster-data"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
