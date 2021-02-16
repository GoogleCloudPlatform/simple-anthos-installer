# [Terragrunt](https://github.com/gruntwork-io/terragrunt) cloud builder with AWS CLI installed

## Terragrunt cloud builder
This builder can be used to run the terragrunt tool in Google Cloud Build with the AWS CLI installed. 

[Terragrunt](https://github.com/gruntwork-io/terragrunt) is a wrapper for [Terraform](https://www.terraform.io/):

### Building this builder
To build this builder, run the following command in this directory.
```sh
gcloud builds submit --config=cloudbuild.yaml
```

## Using this builder

### Terragrunt backend

Terragrunt builder is based on Terraform builder [link](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/terraform). Most of the details about backend are the same as for terraform. Please check examples for the differences and example configuration [link](examples/gcs_backend/README.markdown)
