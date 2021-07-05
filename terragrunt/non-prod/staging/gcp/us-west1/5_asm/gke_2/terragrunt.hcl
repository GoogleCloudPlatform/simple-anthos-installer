/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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

  config_path = "../../2_gke/gke_2"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    name     = "fake"
    location = "fake"
    endpoint = "fake"
  }
}

dependencies {
  paths = ["../../3_hub_connect/gke_2", "../../4_acm/gke_2"]
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/asm?ref=v15.0.0"


}


inputs = {

  cluster_name     = dependency.gke.outputs.name
  location         = dependency.gke.outputs.location
  cluster_endpoint = dependency.gke.outputs.endpoint
  enable_all       = true
  asm_version      = "1.9"

}
