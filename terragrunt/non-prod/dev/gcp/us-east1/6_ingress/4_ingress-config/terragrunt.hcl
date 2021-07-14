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

dependency "ingress-external-ip" {

  config_path = "../1_ingress-external-ip"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    addresses     = ["mock"]

  }
}


# Create the kustomize file to apply to base config with LB IP address and managed certificate name
# This code automates the following step https://cloud.google.com/architecture/exposing-service-mesh-apps-through-gke-ingress#deploy_the_ingress_resource
# Except we are using networking.gke.io/pre-shared-cert tag instead of networking.gke.io/managed-certificates 
# See this github issue here for more info: https://github.com/hashicorp/terraform-provider-kubernetes/issues/446
generate "kustomize_ingress" {
  path      = "configs/ingress-kustomize.yaml"
  if_exists = "overwrite"
  contents = <<EOF
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: gke-ingress
    namespace: istio-system
    annotations:
      kubernetes.io/ingress.global-static-ip-name: "${dependency.ingress-external-ip.outputs.names[0]}"
      networking.gke.io/managed-certificates: "${local.environment_name}-gke-ingress-cert"
EOF
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-gcloud//modules/kubectl-wrapper?ref=v3.0.0"

}


inputs = {

  cluster_name     = dependency.gke.outputs.name
  cluster_location = dependency.gke.outputs.location

  kubectl_create_command  = "kubectl apply -k configs"
  kubectl_destroy_command = "kubectl delete -k configs"
}
