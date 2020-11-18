# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  project_id = get_env("PROJECT_ID") # GCP Project name
  aws_region = "us-east-1" #AWS Region
}
