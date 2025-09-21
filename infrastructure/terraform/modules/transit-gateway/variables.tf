variable "vpc_c1_id" {
  description = "VPC ID for C1 cluster"
  type        = string
}

variable "vpc_c2_id" {
  description = "VPC ID for C2 cluster"
  type        = string
}

variable "vpc_c1_private_subnets" {
  description = "Private subnet IDs for C1 cluster"
  type        = list(string)
}

variable "vpc_c2_private_subnets" {
  description = "Private subnet IDs for C2 cluster"
  type        = list(string)
}

variable "vpc_c1_cidr" {
  description = "CIDR block for C1 VPC"
  type        = string
}

variable "vpc_c2_cidr" {
  description = "CIDR block for C2 VPC"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
