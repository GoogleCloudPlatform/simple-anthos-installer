
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
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment_name = local.environment_vars.locals.environment_name
}

dependencies {
  paths = ["../3_workload_identity"]
}

dependency "gke" {

  config_path = "../2_gke"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    name     = "fake"
    location = "fake"
    endpoint = "fake"
  }
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/hub?ref=v13.0.0"
}


inputs = {


  cluster_name            = dependency.gke.outputs.name
  location                = dependency.gke.outputs.location
  cluster_endpoint        = dependency.gke.outputs.endpoint
  gke_hub_membership_name = dependency.gke.outputs.name
  gke_hub_sa_name         = "gke-hub-sa-2"
  labels                  = "env=${local.environment_name},location=${dependency.gke.outputs.location}"

}
