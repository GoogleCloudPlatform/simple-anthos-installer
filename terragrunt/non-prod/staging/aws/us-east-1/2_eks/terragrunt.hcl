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

dependency "vpc" {

  config_path = "../1_vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {

    private_subnets = ["fake"]
    vpc_id          = ["fake"]
  }
}

terraform {

  source = "../../../../../../modules/aws/eks"

}

inputs = {

  aws_region = local.aws_region
  #Include the GCP project name in naming the resources so we know which GCP project created it
  cluster_name    = "eks-${local.environment_name}-01"
  vpc_id          = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnets
  additional_tags = { env = "${local.environment_name}"
    gke-project = "${local.project_id}"
  }
}
