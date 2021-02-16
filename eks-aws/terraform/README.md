# Creates a VPC and EKS Cluster on AWS

## About the Terraform Files

1. vpc.tf - creates a new vpc, subnet and AZ's
2. security-groups.tf - create SG's required by EKS
3. eks-cluster.tf - creates a private EKS cluster and bastion server to access cluster using AWS EKS module
4. versions.tf - sets TF to at least 0.12 version

