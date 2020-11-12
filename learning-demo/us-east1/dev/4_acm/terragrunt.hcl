# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


dependency "gke" {

  config_path = "../2_gke"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    name = "fake"
  }
}

terraform {

  source = "git::https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/acm?ref=v12.0.0"
}

inputs = {

  
  cluster_name     = dependency.gke.outputs.name
  location         = dependency.gke.outputs.location
  cluster_endpoint = dependency.gke.outputs.endpoint

  sync_repo   = "git@github.com:GoogleCloudPlatform/csp-config-management.git"
  sync_branch = "1.0.0"
  policy_dir  = "foo-corp"

}
