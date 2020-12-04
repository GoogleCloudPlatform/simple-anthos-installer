
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

  region = local.region_vars.locals.region

  #Subnets for GKE
  subnet_01 = "${local.environment_name}-${local.region}-subnet-01"
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-network.git?ref=v2.5.0"
}

inputs = {

  network_name = "${local.environment_name}-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.subnet_01}"
      subnet_ip             = "10.4.0.0/22"
      subnet_region         = "${local.region}"
      subnet_private_access = "true"
    },
  ]
  secondary_ranges = {
    "${local.subnet_01}" = [
      {
        range_name    = "${local.subnet_01}-secondary-range-01-pod"
        ip_cidr_range = "10.0.0.0/14"
      },
      {
        range_name    = "${local.subnet_01}-secondary-range-02-svc"
        ip_cidr_range = "10.5.0.0/20"
      },
      {
        range_name    = "${local.subnet_01}-secondary-range-03-svc"
        ip_cidr_range = "10.5.16.0/20"
      },
      {
        range_name    = "${local.subnet_01}-secondary-range-04-svc"
        ip_cidr_range = "10.5.32.0/20"
      },
    ]
  }
}
