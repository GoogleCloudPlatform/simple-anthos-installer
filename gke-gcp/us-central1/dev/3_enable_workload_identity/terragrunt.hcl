
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

  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/workload-identity?ref=v12.1.0"
}

inputs = {

  name                = "iden-${dependency.gke.outputs.name}"
  namespace           = "default"
  use_existing_k8s_sa = false

}
