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
  region_1    = local.region_vars.locals.region

  # The second region 
  region_2 = "us-west1"

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))


  environment_name = local.environment_vars.locals.environment_name



  #Subnets for GKE
  # gke-01
  subnet_01 = "${local.environment_name}-${local.region}-subnet-01"

  # gke-02
  subnet_02 = "${local.environment_name}-${local.region}-subnet-02"

}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-network?ref=v3.3.0"
}

dependencies {
  paths = ["../0_activate-apis"]
}


inputs = {

  network_name = "${local.environment_name}-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.subnet_01}"
      subnet_ip             = "10.4.0.0/22"
      subnet_region         = "${local.region_1}"
      subnet_private_access = "true"
      description           = "This subnet is managed by Terraform"
    },
    {
      subnet_name           = "${local.subnet_02}"
      subnet_ip             = "10.5.0.0/22"
      subnet_region         = "${local.region_2}"
      subnet_private_access = "true"
      description           = "This subnet is managed by Terraform"
    },
  ]
  secondary_ranges = {
    "${local.subnet_01}" = [
      {
        range_name    = "${local.subnet_01}-secondary-range-01-pod"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "${local.subnet_01}-secondary-range-02-svc"
        ip_cidr_range = "192.168.64.0/18"
      },
    ],
    "${local.subnet_02}" = [
      {
        range_name    = "${local.subnet_02}-secondary-range-01-pod"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "${local.subnet_02}-secondary-range-02-svc"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}
