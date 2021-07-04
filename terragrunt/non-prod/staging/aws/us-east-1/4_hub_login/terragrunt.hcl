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

    cluster_name     = "fake"
    cluster_endpoint = "https://fake"
    cluster_ca_cert  = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNZekNDQWN5Z0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRVUZBREF1TVFzd0NRWURWUVFHRXdKVlV6RU0gCk1Bb0dBMVVFQ2hNRFNVSk5NUkV3RHdZRFZRUUxFd2hNYjJOaGJDQkRRVEFlRncwNU9URXlNakl3TlRBd01EQmEgCkZ3MHdNREV5TWpNd05EVTVOVGxhTUM0eEN6QUpCZ05WQkFZVEFsVlRNUXd3Q2dZRFZRUUtFd05KUWsweEVUQVAgCkJnTlZCQXNUQ0V4dlkyRnNJRU5CTUlHZk1BMEdDU3FHU0liM0RRRUJBUVVBQTRHTkFEQ0JpUUtCZ1FEMmJaRW8gCjd4R2FYMi8wR0hrck5GWnZseEJvdTl2MUptdC9QRGlUTVB2ZThyOUZlSkFRMFFkdkZTVC8wSlBRWUQyMHJIMGIgCmltZERMZ05kTnlubXlSb1MyUy9JSW5mcG1mNjlpeWMyRzBUUHlSdm1ISWlPWmJkQ2QrWUJIUWkxYWRrajE3TkQgCmNXajZTMTR0VnVyRlg3M3p4MHNOb01TNzlxM3R1WEtyRHN4ZXV3SURBUUFCbzRHUU1JR05NRXNHQ1ZVZER3R0cgCitFSUJEUVErRXp4SFpXNWxjbUYwWldRZ1lua2dkR2hsSUZObFkzVnlaVmRoZVNCVFpXTjFjbWwwZVNCVFpYSjIgClpYSWdabTl5SUU5VEx6TTVNQ0FvVWtGRFJpa3dEZ1lEVlIwUEFRSC9CQVFEQWdBR01BOEdBMVVkRXdFQi93UUYgCk1BTUJBZjh3SFFZRFZSME9CQllFRkozK29jUnlDVEp3MDY3ZExTd3IvbmFseDZZTU1BMEdDU3FHU0liM0RRRUIgCkJRVUFBNEdCQU1hUXp0K3phajFHVTc3eXpscjhpaU1CWGdkUXJ3c1paV0pvNWV4bkF1Y0pBRVlRWm1PZnlMaU0gCkQ2b1lxK1puZnZNMG44Ry9ZNzlxOG5od3Z1eHBZT25SU0FYRnA2eFNrcklPZVp0Sk1ZMWgwMExLcC9KWDNOZzEgCnN2WjJhZ0UxMjZKSHNRMGJoek41VEtzWWZid2ZUd2ZqZFdBR3k2VmYxbllpL3JPK3J5TU8KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLSAK"
  }
}

dependencies {

  paths = ["../3_hub_connect"]
}


#Generate the K8s provider since it is specific to EKS. More info here: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
generate "k8s_provider" {
  path      = "k8s_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

  provider "kubernetes" {
  host                   = "${dependency.eks.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_ca_cert}")
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.cluster_name}"]
    command     = "aws"
  }
}
EOF
}

terraform {

  # For non GKE clusters we need to get create a KSA and create role bindings. This is done in the below module.
  source = "."

  # Before apply and plan, set the current kubetctl context to the eks cluster so we can run the command above.
  before_hook "before_hook_1" {
    commands = ["apply", "plan"]
    execute  = ["aws", "eks", "--region", "${local.aws_region}", "update-kubeconfig", "--name", "${dependency.eks.outputs.cluster_name}"]
  }

}


