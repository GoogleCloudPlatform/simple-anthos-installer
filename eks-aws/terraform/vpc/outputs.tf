output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "VPC ID"
  value       = module.vpc.private_subnets
}

