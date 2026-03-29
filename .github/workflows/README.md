# GitHub Actions: Deploy to GCP Kubernetes

This workflow deploys the application to GCP GKE whenever a pull request is merged into `main`.

## Required GitHub Secrets

Configure these in your repository under **Settings > Secrets and variables > Actions**:

| Secret | Description |
|--------|-------------|
| `GCP_PROJECT_ID` | Your GCP project ID (e.g. `my-project-123`) |
| `GCP_SA_KEY` | JSON key of a GCP service account with required permissions |
| `GKE_CLUSTER` | Name of your GKE cluster |
| `GKE_ZONE` | Zone or region of your GKE cluster (e.g. `us-central1-a`) |

## Required Service Account Permissions

The service account (`GCP_SA_KEY`) needs these IAM roles:

- `roles/container.developer` — to deploy to GKE
- `roles/storage.admin` — to push images to GCR

## Deployment Assumptions

- Your Kubernetes deployment is named `app` and the container is also named `app`.
  Update the `kubectl set image` command in the workflow if they differ.
- A `Dockerfile` exists at the root of the repository.

## Workload Identity Federation (optional)

For keyless authentication, replace the `credentials_json` auth step with
`workload_identity_provider` + `service_account` and add these secrets:

| Secret | Description |
|--------|-------------|
| `WIF_PROVIDER` | Full WIF provider resource name |
| `WIF_SERVICE_ACCOUNT` | Service account email for WIF |
