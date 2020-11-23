
# Automates obtaining the token required to log into a cluster from the Cloud Console 
# Automates manual instructions from the doc here: https://cloud.google.com/anthos/multicluster-management/console/logging-in
# upto token generation. Copy and paste the token from the output of this module to the Cloud Console. 



# This loads the current context. It is assumed that the current context is set to the cluster we want 
# to log into.
provider "kubernetes" {
  
}

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

  depends_on = [ module.gke_hub_registration ]
}

data "kubernetes_secret" "ksa_secret" {
  metadata {
    name      = "${kubernetes_service_account.remote-admin-sa.default_secret_name}"
    namespace = "${kubernetes_service_account.remote-admin-sa.metadata.0.namespace}"
  }
}



