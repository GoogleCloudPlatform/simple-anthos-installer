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


dependencies {
  paths = ["../../4_acm/gke_1"]
}

terraform {

  source = "."
}


inputs = {

  name                  = "self-signed-ingress-gateway-cert"
  validity_period_hours = 9552 # Max life of TLS cert is 398 days
  ca_common_name        = "Self signed CA for mesh ingress gateway"
  organization_name     = "Simple_Anthos-Installer"
  common_name           = "${local.environment_name}-frontend.endpoints.${local.project_id}.cloud.goog"
  #dns_names             = var.dns_names
  #ip_addresses          = var.ip_addresses
  download_certs = true

}
