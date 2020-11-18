# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      backend "gcs" {}
    }
  EOF
}


locals {

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment_name = local.environment_vars.locals.environment_name

  aws_region = local.region_vars.locals.aws_region

}

dependency "vpc" {

  config_path = "../1_vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
   
    private_subnets = ["fake"]
    vpc_id = ["fake"]
  }
}

terraform {

  source = "../../../terraform/eks/"
}

inputs = {

    aws_region = local.aws_region
    cluster_name = "eks-${local.environment_name}-01"
    vpc_id = dependency.vpc.outputs.vpc_id
    private_subnets = dependency.vpc.outputs.private_subnets
}
