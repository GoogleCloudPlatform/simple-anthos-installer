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

dependency "ingress-dns" {

  config_path = "../2_ingress-dns"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    endpoint     = "fake"
  }
}

generate "kustomize_ingress" {
  path      = "managed-cert.yaml"
  if_exists = "overwrite"
  contents = <<EOF
  apiVersion: networking.gke.io/v1beta2
  kind: ManagedCertificate
  metadata:
    name: ${local.environment_name}-gke-ingress-cert
    namespace: istio-system
  spec:
    domains:
      - "${dependency.ingress-dns.outputs.endpoint}"
EOF
}

terraform {

   source = "github.com/terraform-google-modules/terraform-google-gcloud//modules/kubectl-wrapper?ref=v3.0.0"

}


inputs = {

  cluster_name     = dependency.gke.outputs.name
  cluster_location = dependency.gke.outputs.location

  kubectl_create_command  = "kubectl apply -f managed-cert.yaml"
  kubectl_destroy_command = "kubectl delete -f managed-cert.yaml"

}
