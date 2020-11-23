
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
  cluster_type = "gke-regional"

}

dependency "vpc" {

  config_path = "../1_vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    network_name  = "fake-network"
    subnets_names = ["fake-subnetwork"]
  }
}

terraform {

  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git?ref=v12.1.0"
}


inputs = {

  name              = "${local.cluster_type}-cluster-${local.environment_name}-01"
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
      name         = "node-pool"
      autoscaling  = false
      auto_upgrade = true
      # Try to set  node pool to 4 for ACM to prevent against test flakiness
      node_count   = 2
      machine_type = "e2-standard-4"
    },
  ]
}
