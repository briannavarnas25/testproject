#!/bin/bash
set -euo pipefail

# -----------------------------------------------
# GCP / GKE Setup Script
# Project : project-fa61e5b8-65ad-4d23-b85
# Cluster : clusterone
# Zone    : us-east1-b
# -----------------------------------------------

PROJECT_ID="project-fa61e5b8-65ad-4d23-b85"
CLUSTER_NAME="clusterone"
ZONE="us-east1-b"
SA_NAME="github-actions-deployer"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KEY_FILE="sa-key.json"

echo "==> Setting active project"
gcloud config set project "$PROJECT_ID"

echo "==> Enabling required APIs"
gcloud services enable \
  container.googleapis.com \
  containerregistry.googleapis.com \
  iam.googleapis.com

echo "==> Creating GKE cluster: $CLUSTER_NAME"
gcloud container clusters create "$CLUSTER_NAME" \
  --zone "$ZONE" \
  --num-nodes 1 \
  --machine-type e2-medium \
  --disk-size 20GB \
  --enable-autoupgrade \
  --enable-autorepair

echo "==> Creating service account: $SA_NAME"
gcloud iam service-accounts create "$SA_NAME" \
  --display-name "GitHub Actions GKE Deployer"

echo "==> Granting IAM roles to service account"
# Push images to GCR
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member "serviceAccount:${SA_EMAIL}" \
  --role "roles/storage.admin"

# Deploy to GKE
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member "serviceAccount:${SA_EMAIL}" \
  --role "roles/container.developer"

echo "==> Generating service account key -> $KEY_FILE"
gcloud iam service-accounts keys create "$KEY_FILE" \
  --iam-account "$SA_EMAIL"

echo ""
echo "================================================================"
echo " Setup complete! Next steps:"
echo "================================================================"
echo ""
echo " 1. Add the following secrets to your GitHub repository:"
echo "    Settings > Secrets and variables > Actions > New secret"
echo ""
echo "    GCP_PROJECT_ID  = $PROJECT_ID"
echo "    GKE_CLUSTER     = $CLUSTER_NAME"
echo "    GKE_ZONE        = $ZONE"
echo "    GCP_SA_KEY      = (paste the entire contents of $KEY_FILE)"
echo ""
echo " 2. View the key file with:"
echo "    cat $KEY_FILE"
echo ""
echo " 3. After adding the secrets, DELETE the key file:"
echo "    rm $KEY_FILE"
echo ""
echo " 4. Your GKE credentials are now configured locally."
echo "    Verify with: kubectl get nodes"
echo "================================================================"
