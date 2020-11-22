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

locals {
  gke_hub_sa_key = var.use_existing_sa ? var.sa_private_key : google_service_account_key.gke_hub_key[0].private_key
}

data "google_client_config" "default" {
}

resource "google_service_account" "gke_hub_sa" {
  count        = var.use_existing_sa ? 0 : 1
  account_id   = var.gke_hub_sa_name
  project      = var.project_id
  display_name = "Service Account for GKE Hub Registration"

}

resource "google_project_iam_member" "gke_hub_member" {
  count   = var.use_existing_sa ? 0 : 1
  project = var.project_id
  role    = "roles/gkehub.connect"
  member  = "serviceAccount:${google_service_account.gke_hub_sa[0].email}"
}

resource "google_service_account_key" "gke_hub_key" {
  count              = var.use_existing_sa ? 0 : 1
  service_account_id = google_service_account.gke_hub_sa[0].name
}

# Need to make sure kubectl is set to the correct context before this is run.
module "gke_hub_registration" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0.2"

  platform                          = "linux"
  gcloud_sdk_version                = var.gcloud_sdk_version
  upgrade                           = true
  use_tf_google_credentials_env_var = var.use_tf_google_credentials_env_var
  module_depends_on                 = concat([var.cluster_endpoint], var.module_depends_on)

  skip_download = true
  create_cmd_entrypoint  = "${path.module}/scripts/k8s_hub_registration.sh"
  create_cmd_body        = "${var.gke_hub_membership_name} ${local.gke_hub_sa_key} ${var.project_id}"
  destroy_cmd_entrypoint = "${path.module}/scripts/k8s_hub_unregister.sh"
  destroy_cmd_body       = "${var.gke_hub_membership_name} ${var.project_id}"
}
