variable "aws_region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets" {
  description = "Private subnet array"
  type = list(string)
}


