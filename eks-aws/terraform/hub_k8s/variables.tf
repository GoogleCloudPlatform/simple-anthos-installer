/**
 * Copyright 2018 Google LLC
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

variable "cluster_name" {
  description = "The EKS cluster name."
  type        = string
}

variable "region" {
  description = "AWS region where the EKS cluster is located."
  type        = string
}

variable "labels" {
  description = "comma separated labels to apply to cluster in the GCP Console"
  type = string
}

variable "cluster_endpoint" {
  description = "The GKE cluster endpoint."
  type        = string
}

variable "kubeconfig" {
  description = "kubectl config file contents of the K8s cluster to register with hub"
  type        = string
  
}
variable "project_id" {
  description = "The GCP project in which the hub belongs."
  type        = string
}


variable "use_tf_google_credentials_env_var" {
  description = "Optional GOOGLE_CREDENTIALS environment variable to be activated."
  type        = bool
  default     = false
}

variable "gcloud_sdk_version" {
  description = "The gcloud sdk version to use. Minimum required version is 293.0.0"
  type        = string
  default     = "296.0.1"
}

variable "enable_gke_hub_registration" {
  description = "Enables GKE Hub Registration when set to true"
  type        = bool
  default     = true
}

variable "gke_hub_sa_name" {
  description = "Name for the GKE Hub SA stored as a secret `creds-gcp` in the `gke-connect` namespace."
  type        = string
  default     = "gke-hub-sa"
}

variable "gke_hub_membership_name" {
  description = "Membership name that uniquely represents the cluster being registered on the Hub"
  type        = string
  default     = "gke-hub-membership"
}

variable "use_existing_sa" {
  description = "Uses an existing service account to register membership. Requires sa_private_key"
  type        = bool
  default     = false
}

variable "sa_private_key" {
  description = "Private key for service account base64 encoded. Required only if `use_existing_sa` is set to `true`."
  type        = string
  default     = null
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on."
  type        = list
  default     = []
}
