variable "aws_region" {
  description = "AWS region"
}

variable "environment_name" {
  description = "Environment Name"
}


data "aws_availability_zones" "available" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name                 = "${var.environment_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.environment_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.environment_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.environment_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
