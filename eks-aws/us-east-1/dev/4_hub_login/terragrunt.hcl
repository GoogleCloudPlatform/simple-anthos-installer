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

  cluster_name = "remote-${local.environment_name}-${local.project_id}-1"
}

dependency "eks" {

  config_path = "../2_eks"

}

dependencies {

  paths = ["../3_hub"]
}

#Generate the K8s provider since it is specific to EKS. More info here: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
generate "k8s_provider" {
  path      = "k8s_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

  provider "kubernetes" {
  host                   = "${dependency.eks.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_ca_cert}")
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.cluster_name}"]
    command     = "aws"
  }
}
EOF
}

terraform {

  source = "../../../terraform/hub_login"

  # Before apply and plan to set the current kubetctl context to the eks cluster
  before_hook "before_hook_1" {
    commands = ["apply", "plan"]
    execute  = ["aws", "eks", "--region", "${local.aws_region}", "update-kubeconfig", "--name", "${local.cluster_name}"]
  }

}

inputs = {


}

