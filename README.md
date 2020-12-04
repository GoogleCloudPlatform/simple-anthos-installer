![Logo](images/logo.png)
# A Simple Anthos Installer

Automated install of Anthos multi cloud using [Google Cloud best practices](https://cloud.google.com/foundation-toolkit):

<img align="right" src="./docs/assets/release-it.gif?raw=true" height="280">

- Deploys 2 Clusters 
- A GKE Cluster on GCP in a dedicated VPC
- A EKS Cluster on AWS in a dedicated VPC
- [Connects](https://cloud.google.com/anthos/multicluster-management/connect/overview) both clusters to Anthos
- Enables [Anthos Config Management (ACM)](https://cloud.google.com/anthos/config-management) on both clusters 

<p>
<details>
  <summary><strong>Table of Contents</strong> (click to expand)</summary>

<!-- toc -->
- [Usage](#usage)
- [Configuration](#configuration)
- [Changelog](#changelog)
- [Resources](#resources)

<!-- tocstop -->

</details>
</p>

## Usage

## Pre-requisites

- [gcloud](https://cloud.google.com/sdk/docs/install) installed and configured
```bash
export PROJECT_ID="<GCP_PROJECTID>"
gcloud config set core/project ${PROJECT_ID}  
```
- Permission to create GKE Clusters and Anthos API enabled.
- SSH public key registered with Cloud Build Project (https://source.cloud.google.com/user/ssh_keys)
- Cloud Build enabled (if using it to deploy)
- AWS Account credentials stored in Secret Manager for EKS deploy.
  - Access Key stored with key `aws-access-key`
  - Secret key stored with key  `aws-secret-access-key`

## Quick Start
The quickest way to deploy us using Google Cloud Build.

### Permissions
- Ensure Cloud Build service account permission has Kubernetes Engine, Service Account and Secrets Manager enabled.

### Clone the repo

```bash
git clone ssh://<user>@google.com@source.developers.google.com:2022/p/east-mfg-ce/r/anthos-edgeML-demo-live
```

### Build the Cloud Build Container images
This will build the container images with Terragrunt so cloud build and deploy

```bash
 cd cloudbuild/terragrunt
 gcloud builds submit --config=cloudbuild.yaml

 cd ../terragrunt-awscli
 gcloud builds submit --config=cloudbuild.yaml
```

### Deploy GKE Cluster with ACM and Connect to Anthos

```bash
 gcloud builds submit . --config=cloudbuild-gke-dev-deploy.yaml --timeout=30m
```

### Deploy EKS Cluster with ACM and Connect to Anthos 

```bash
 gcloud builds submit . --config=cloudbuild-eks-dev-deploy.yaml --timeout=30m
```

- In order to get the green check on the EKS cluster in the Anthos Dashbaord, we have to [Login to the Cluster](https://cloud.google.com/anthos/multicluster-management/console/logging-in#login) using a KSA token. This is a manual step. Go to the Cloud Build output for the EKS Hub module and look for the output value for `ksa_token`. Use this token to Login to the console from the Anthos Clusters page. 

