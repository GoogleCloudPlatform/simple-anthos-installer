![Logo](images/logo.png)
# A Simple Anthos Installer

Automated Anthos Multi Cloud installer in 3 easy steps!

- Deploys 2 Clusters 
  - A GKE Cluster on GCP in a dedicated VPC
  - A EKS Cluster on AWS in a dedicated VPC
- [Runs GKE Connect](https://cloud.google.com/anthos/multicluster-management/connect/overview) on both clusters and creates Kubernetes Service Account to use to login to the Anthos console for the EKS Cluster.
- Enables [Anthos Config Management (ACM)](https://cloud.google.com/anthos/config-management) on both clusters 
- Uses [CFT](https://cloud.google.com/foundation-toolkit) Terraform modules that follow best practices.

<p>
<details>
  <summary><strong>Table of Contents</strong> (click to expand)</summary>

<!-- toc -->
- [Pre-requisites](#Pre-requisites)
- [Usage](#Usage)
- [Cleanup](#Cleanup)

<!-- tocstop -->

</details>
</p>

## Pre-requisites

- [gcloud](https://cloud.google.com/sdk/docs/install) installed and configured
```bash
export PROJECT_ID="<GCP_PROJECTID>"
gcloud config set core/project ${PROJECT_ID}  
```
- Permission to create GKE Clusters and Anthos API enabled.
- - Cloud Build enabled and your SSH public key registered with Cloud Build Project (https://source.cloud.google.com/user/ssh_keys)

- AWS Account credentials stored in Secret Manager for EKS deploy.
  - Access Key stored with key `aws-access-key`
  - Secret key stored with key  `aws-secret-access-key`

## Usage
The quickest way to deploy is using Google Cloud Build.

### Permissions
- Ensure Cloud Build service account permission has Kubernetes Engine, Service Account and Secrets Manager enabled.


### 0. Clone the repo

```bash
git clone sso://user/arau/simple-anthos
cd simple-anthos
```

### 1. Build the Cloud Build Container images
This will build the container images used for our Cloud Build deploy scripts. They container image contains gcloud, terraform, terragrunt and aws-cli installed.

```bash
 
 cd cloudbuild/terragrunt-awscli
 gcloud builds submit --config=cloudbuild.yaml

```

### 2. Create or clone a git repo you want to use for ACM

By default it uses the reference repo here [git@github.com:GoogleCloudPlatform/csp-config-management.git](https://github.com/GoogleCloudPlatform/csp-config-management)

To change this to use your own repo, clone the above [repo](https://github.com/GoogleCloudPlatform/csp-config-management) and modify the `sync_repo` variable in the  files  [gke-gcp/us-central1/dev/5_acm/terragrunt.hcl](gke-gcp/us-central1/dev/5_acm/terragrunt.hcl) and [eks-aws/us-east-1/dev/4_acm/terragrunt.hcl](eks-aws/us-east-1/dev/4_acm/terragrunt.hcl) to point to your repo.

### 3. Create the Clusters

#### Create GKE Cluster on GCP

```bash
cd ../..
gcloud builds submit . --config=cloudbuild-gke-dev-deploy.yaml --timeout=30m
```

#### Create EKS Cluster on AWS 

```bash
 gcloud builds submit . --config=cloudbuild-eks-dev-deploy.yaml --timeout=30m
```

In order to get the green check on the EKS cluster in the Anthos Dashbaord, we have to [Login to the Cluster](https://cloud.google.com/anthos/multicluster-management/console/logging-in#login) using a KSA token. This is a manual step. 
- Go to the Cloud Build output for the EKS Hub module and look for the output value for `ksa_token`. Use this token to Login to the console from the Anthos Clusters page. 

### Enjoy!

Now you have a 2 clusters connected to an envrion (your GCP project) with ACM enabled. 

## Cleanup
```bash
gcloud builds submit . --config=cloudbuild-eks-dev-destroy.yaml --timeout=30m

gcloud builds submit . --config=cloudbuild-gke-dev-destroy.yaml --timeout=30m
```

The abpove cleanup will fail if your project is in the `gcct-team` folder because the GCE-Enforcer adds firewall rules that prevent the VPC from being deleted. Easier way would be to use a dedicated project. 
