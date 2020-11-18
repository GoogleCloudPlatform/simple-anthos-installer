
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
  aws_region = local.region_vars.locals.aws_region

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
      
    }

    provider "google-beta" {
      region = "${local.region}"
      project = "${local.project_id}"
      
    }

    provider "aws" {
      version = ">= 2.28.1"
      region  = "${local.aws_region}"
    }

    terraform {
      required_version = ">= 0.12"
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
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
  backend      = "gcs"
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
