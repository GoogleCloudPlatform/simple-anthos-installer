# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.

locals {
  region     = "us-central1" # GCP Region
  aws_region = "us-east-1"   #AWS Region
}
