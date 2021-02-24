/**
 * Copyright 2020 Google LLC
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


# Automates obtaining the token required to log into a cluster from the Cloud Console 
# Automates manual instructions from the doc here: https://cloud.google.com/anthos/multicluster-management/console/logging-in
# upto token generation. Copy and paste the token from the output of this module to the Cloud Console. 



# This loads the current context. It is assumed that the current context is set to the cluster we want 
# to log into.

# Create Kubernetes Service Account (KSA)
resource "kubernetes_service_account" "remote-admin-sa" {
  metadata {
    name = "remote-admin-sa"
  }

}

# Assign the KSA it the cluster-admin ClusterRole

resource "kubernetes_cluster_role_binding" "ksa-admin-binding" {
  metadata {
    name = "ksa-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "remote-admin-sa"
    namespace = "default"
  }

  depends_on = [var.module_depends_on]
}

data "kubernetes_secret" "ksa_secret" {
  metadata {
    name      = "${kubernetes_service_account.remote-admin-sa.default_secret_name}"
    namespace = "${kubernetes_service_account.remote-admin-sa.metadata.0.namespace}"
  }
}



