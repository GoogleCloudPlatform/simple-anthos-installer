# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  project_id = get_env("TERRAGRUNT_PROJECT_NAME","arau-anthos") # GCP Project name
}
