
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
  region     = local.region_vars.locals.region

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
    cluster_endpoint = "fake"

  }
}

dependencies {
  paths = ["../4_hub_login"]
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/acm?ref=v13.1.0"


  # Before apply and plan to set the current kubetctl context to the eks cluster
  before_hook "before_hook_1" {
    commands = ["apply", "plan"]
    execute  = ["aws", "eks", "--region", "${local.aws_region}", "update-kubeconfig", "--name", "${dependency.eks.outputs.cluster_name}"]
  }
}


inputs = {

  project_id = local.project_id
  location   = local.aws_region

  cluster_name         = dependency.eks.outputs.cluster_name
  cluster_endpoint     = dependency.eks.outputs.cluster_endpoint
  use_existing_context = true

  sync_repo   = get_env("ACM_REPO", "git@github.com:GoogleCloudPlatform/csp-config-management.git")
  sync_branch = "1.0.0"
  policy_dir  = "foo-corp"

}
