# mathews-recurring-revenue-prd

## Usage

This project is intended to be executed only by CI/CD workflow, do not execute it locally.

## First Time Setup

1. Create a GCP project called "mathews-recurring-revenue-prd" through UI and associate a billing account. If you already have a default billing account, it will be automatically associated.

2. Open a Cloud Shell on the created project to execute all of the commands below.

3. Create a Workload Identity Pool w/ the server name:

```sh
gcloud iam workload-identity-pools create "github" \
  --project="mathews-recurring-revenue-prd" \
  --location="global" \
  --display-name="GitHub Pool"
```

4. Create a Workload Identity Provider w/ the repository name:

```sh
gcloud iam workload-identity-pools providers create-oidc "mathews-recurring-revenue" \
  --project="mathews-recurring-revenue-prd" \
  --location="global" \
  --workload-identity-pool="github" \
  --display-name="GitHub Repo Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository_owner == 'mathewsmachado'" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

5. Extract the Workload Identity Provider name:

```sh
gcloud iam workload-identity-pools providers describe "mathews-recurring-revenue" \
  --project="mathews-recurring-revenue-prd" \
  --location="global" \
  --workload-identity-pool="github" \
  --format="value(name)"
```

6. Create a Service Account:

```sh
gcloud iam service-accounts create github \
    --project="mathews-recurring-revenue-prd" \
    --display-name="GitHub Service Account"
```

7. Bind IAM Policies to the Service Account:

```sh
for role in \
    roles/editor \
    roles/bigquery.admin \
    roles/iam.serviceAccountAdmin \
    roles/iam.serviceAccountTokenCreator \
    roles/resourcemanager.projectIamAdmin \
    roles/storage.admin \
    roles/serviceusage.serviceUsageAdmin; \
    do \
        gcloud projects add-iam-policy-binding mathews-recurring-revenue-prd \
            --member="serviceAccount:github@mathews-recurring-revenue-prd.iam.gserviceaccount.com" \
            --role="$role"; \
    done
```

8. Allow the Workload Identity Pool to impersonate the Service Account:

```sh
gcloud iam service-accounts add-iam-policy-binding \
    "github@mathews-recurring-revenue-prd.iam.gserviceaccount.com" \
    --project="mathews-recurring-revenue-prd" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/753917517701/locations/global/workloadIdentityPools/github/attribute.repository/mathewsmachado/mathews-recurring-revenue"
```

9. Enable IAM API:

```sh
gcloud services enable iamcredentials.googleapis.com \
    --project mathews-recurring-revenue-prd
```

10. Create a Bucket to store Terraform state:

```sh
gcloud storage buckets create gs://mathews-recurring-revenue-prd-terraform-bucket \
    --project=mathews-recurring-revenue-prd \
    --location=us-central1 \
    --uniform-bucket-level-access \
    --public-access-prevention \
    --soft-delete-duration=7d
```
