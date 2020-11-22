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

  # Automatically load project-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment_name = local.environment_vars.locals.environment_name

  aws_region = local.region_vars.locals.aws_region
  #Get the GCP project ID
  project_id = local.account_vars.locals.project_id

}
dependency "eks" {

  config_path = "../2_eks"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {

    cluster_name            = ["fake"]
    cluster_endpoint        = ["fake"]
    region                  = ["fake"]
    cluster_endpoint        = ["fake"]
    kubeconfig              = ["fake"]
    gke_hub_membership_name = ["fake"]
  }
}

terraform {

  source = "../../../terraform/hub_eks/"

  # Before apply and plan to set the current kubetctl context to the eks cluster
  before_hook "before_hook_1" {
    commands     = ["apply", "plan"]
    execute      = ["aws", "eks","--region", "${local.aws_region}", "update-kubeconfig", "--name", "${dependency.eks.outputs.cluster_name}"]
  }

}

inputs = {
  cluster_name            = dependency.eks.outputs.cluster_name
  region                  = dependency.eks.outputs.region
  cluster_endpoint        = dependency.eks.outputs.cluster_endpoint
  kubeconfig              = dependency.eks.outputs.kubeconfig
  gke_hub_membership_name = dependency.eks.outputs.cluster_name
  project_id              = local.project_id
}
