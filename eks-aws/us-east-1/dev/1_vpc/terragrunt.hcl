
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

terraform {

  source = "../../../terraform/vpc/"
}

inputs = {

  #Include the GCP project name in naming the resources so we know which GCP project created it
  environment_name = "${local.environment_name}-gcp:${local.project_id}"
  additional_tags = { env = local.environment_name
                      createdByGCPProject = local.project_id
                    }
  
}
