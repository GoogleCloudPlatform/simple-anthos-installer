# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.

locals {
  region             = get_env("GCP_REGION", "us-central1") # GCP Region
  availability_zones = get_env("GCP_AZS", ["us-central1-b", "us-central1-c", "us-central1-a"])
  aws_region         = get_env("AWS_REGION", "us-east-1") #AWS Region
}
