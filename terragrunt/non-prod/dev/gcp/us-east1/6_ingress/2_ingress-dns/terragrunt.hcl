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

dependency "ingress-external-ip" {

  config_path = "../1_ingress-external-ip"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    addresses = ["mock-address"]

  }
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-endpoints-dns?ref=v2.0.1"

}


inputs = {
  project     = local.project_id
  name        = "${local.environment_name}-frontend"
  external_ip = dependency.ingress-external-ip.outputs.addresses[0]

}
