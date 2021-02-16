# Set common variables for the envrionment. This is automatically pulled in in the root terragrunt.hcl configuration to
# and pass forward to the child modules as inputs.
locals {
  environment_name = get_env("ENVIRONMENT_NAME", "dev")
}
