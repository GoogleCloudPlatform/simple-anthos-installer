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


locals {
  # Automatically load project-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  project_id       = local.account_vars.locals.project_id
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment_name = local.environment_vars.locals.environment_name
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

  config_path = "../../2_gke/gke_1"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    name     = "fake"
    location = "fake"
    endpoint = "fake"
  }
}

dependency "gateway_cert" {

  config_path = "../1_create-gateway-cert"


}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-gcloud//modules/kubectl-wrapper?ref=v3.0.0"

  # Save the certificate content to files before apply
  before_hook "before_hook_save_private_key" {
    commands = ["apply", ]
    execute  = ["/bin/bash", "-c", "echo '${chomp(dependency.gateway_cert.outputs.ca_private_key_pem)}' >  ${local.environment_name}-frontend.endpoints.${local.project_id}.cloud.goog.key"]
  }

  before_hook "before_hook_save_public_key" {
    commands = ["apply", ]
    execute  = ["/bin/bash", "-c", "echo '${chomp(dependency.gateway_cert.outputs.ca_cert_pem)}' >  ${local.environment_name}-frontend.endpoints.${local.project_id}.cloud.goog.crt"]
  }

  # Delete the certificate files after apply
  after_hook "after_hook_delete_private_key" {
    commands = ["apply", ]
    execute  = ["/bin/bash", "-c", "rm -f frontend.endpoints.${local.project_id}.cloud.goog.key"]
  }

  after_hook "after_hook_delete_public_key" {
    commands = ["apply", ]
    execute  = ["/bin/bash", "-c", "rm -f frontend.endpoints.${local.project_id}.cloud.goog.crt"]
  }

}


inputs = {

  cluster_name     = dependency.gke.outputs.name
  cluster_location = dependency.gke.outputs.location

  kubectl_create_command  = "kubectl -n istio-system create secret tls edge2mesh-credential --key=${local.environment_name}-frontend.endpoints.${local.project_id}.cloud.goog.key --cert=${local.environment_name}-frontend.endpoints.${local.project_id}.cloud.goog.crt"
  kubectl_destroy_command = "kubectl -n istio-system delete secrets edge2mesh-credential"
}
