# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.

locals {
  region             = get_env("GCP_REGION", "us-east1") # GCP Region
  availability_zones = split(",", get_env("GCP_AZS", "us-east1-b,us-east1-c,us-east1-d"))
  aws_region         = get_env("AWS_REGION", "us-east-1") #AWS Region - not used by GKE install but required so Terragrunt is happy
}
