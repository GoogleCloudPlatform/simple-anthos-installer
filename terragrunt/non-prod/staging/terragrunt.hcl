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

/*
 This file contains the common providers that are used by child terragrunt modules. 
 It is best practice to use versioned providers so modify this file with care
 */

locals {
  # Automatically load project-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  project_id = local.account_vars.locals.project_id
  region     = local.region_vars.locals.region
  
  environment_name = local.environment_vars.locals.environment_name
}

# Generate an GCP provider block

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF


    provider "google" {
      region = "${local.region}"
      project = "${local.project_id}"
      version = "~> 3.70"
      
    }

    provider "google-beta" {
      region = "${local.region}"
      project = "${local.project_id}"
      version = "~> 3.70"
    }

    terraform {
      required_version = ">= 0.13"
    }

    provider "random" {
      version = "~> 2.1"
    }

    provider "local" {
      version = "~> 1.2"
    }

    provider "null" {
      version = "~> 2.1"
    }

    provider "template" {
      version = "~> 2.1"
    }
EOF
}

# Configure terraform state to be stored in GCS,
remote_state {
  # Variable to control if the GCS bucket gets created or not. See https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))

  backend = "gcs"
  config = {
    project  = local.project_id
    location = local.region
    bucket   = "terraform-state-${local.environment_name}-${local.project_id}-${local.region}"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"

    gcs_bucket_labels = {
      owner = "${local.project_id}"
      name  = "${local.environment_name}"
    }

  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)
