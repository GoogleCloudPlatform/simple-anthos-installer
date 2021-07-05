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
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))


  environment_name = local.environment_vars.locals.environment_name

  region             = local.region_vars.locals.region
  availability_zones = local.region_vars.locals.availability_zones

  #Subnets for GKE
  subnet_01    = "${local.environment_name}-${local.region}-subnet-01"
  cluster_type = "gke"

}

dependency "vpc" {

  config_path = "../../1_vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    network_name  = "fake-network"
    subnets_names = ["fake-subnetwork"]
  }
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine?ref=v15.0.0"
}


inputs = {

  name              = "${local.cluster_type}-${local.environment_name}-01"
  regional          = true
  zones             = local.availability_zones
  network           = dependency.vpc.outputs.network_name
  subnetwork        = dependency.vpc.outputs.subnets_names[0]
  ip_range_pods     = "${local.subnet_01}-secondary-range-01-pod"
  ip_range_services = "${local.subnet_01}-secondary-range-02-svc"
  service_account   = "create"
  release_channel   = "REGULAR"
  node_pools = [
    {
      name         = "${local.cluster_type}-${local.environment_name}-01-pool"
      autoscaling  = false
      auto_upgrade = true
      node_count   = 1
      machine_type = "e2-standard-4"
    },
  ]
}
