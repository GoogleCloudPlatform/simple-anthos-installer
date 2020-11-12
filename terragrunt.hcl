# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Automatically load project-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  project_id         = local.account_vars.locals.project_id
  region             = local.region_vars.locals.region
  availability_zones = local.region_vars.locals.availability_zones

}

# Generate an GCP provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF


    provider "google" {
      region = "${local.region}"
      project = "${local.project_id}"
      
    }

    provider "google-beta" {
      region = "${local.region}"
      project = "${local.project_id}"
      
    }

    provider "null" {
      version = "~> 2.1"
    }

EOF
}

# Configure terraform state to be stored in GCS,
remote_state {
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    project  = local.project_id
    location = "eu"
    bucket   = "${get_env("TG_BUCKET_PREFIX", "")}terragrunt-terraform-state-${local.project_id}-${local.region}"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"

    gcs_bucket_labels = {
      owner = "terragrunt"
      name  = "terraform"
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
