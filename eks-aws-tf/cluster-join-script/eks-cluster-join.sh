
#!/usr/bin/env bash

#create service account

gcloud iam service-accounts create anthos-hub \
  --project=${PROJECT}

# add iam policy binding

gcloud projects add-iam-policy-binding gagan-internal-projects \
 --member="serviceAccount:anthos-hub@${PROJECT}.iam.gserviceaccount.com" \
 --role="roles/gkehub.connect"

#Create a JSON file in your local directory which is required to register the cluster

gcloud iam service-accounts keys create ./anthos-hub-svc.json \
  --iam-account="anthos-hub@${PROJECT}.iam.gserviceaccount.com" \
  --project=${PROJECT}

# Add EKS cluster to Anthos

gcloud container hub memberships register gagan-eks \
   --project=${PROJECT} \
   --context=arn:aws:eks:us-east-2:126285863215:cluster/gagantrial-eks-qanFZgUu \
   --kubeconfig=~/.kube/config \
   --service-account-key-file=./anthos-hub-svc.json
