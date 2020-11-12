# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.

locals {
  region             = "us-east1"
  availability_zones = ["us-east1-b", "us-east1-c", "us-east1-d"]
}
