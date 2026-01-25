# mathews-recurring-revenue-dev

## Usage

This project is intended to be executed only manually, do not execute it by CI/CD.

## First Time Setup

1. Create a GCP project called "mathews-recurring-revenue-dev" through UI and associate a billing account. If you already have a default billing account, it will be automatically associated.

2. Enable Credentials API:

```sh
gcloud services enable iamcredentials.googleapis.com \
    --project mathews-recurring-revenue-dev
```
    
3. Create a bucket to store Terraform state:

```sh
gcloud storage buckets create gs://mathews-recurring-revenue-dev-terraform-bucket \
    --project=mathews-recurring-revenue-dev \
    --location=us-central1 \
    --uniform-bucket-level-access \
    --public-access-prevention \
    --soft-delete-duration=7d
```

4. Create a Service Account:

```sh
gcloud iam service-accounts create terraform \
    --project="mathews-recurring-revenue-dev" \
    --display-name="Terraform Service Account"
```

5. Bind IAM Policies to the Service Account:

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
        gcloud projects add-iam-policy-binding mathews-recurring-revenue-dev \
            --member="serviceAccount:terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com" \
            --role="$role"; \
    done
```

6. Allow your user to impersonate the Service Account:

```sh
gcloud iam service-accounts add-iam-policy-binding terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com \
    --project="mathews-recurring-revenue-dev" \
    --member="user:mathews.machadoamorim@gmail.com" \
    --role="roles/iam.serviceAccountTokenCreator"
```

7. Reauthenticate, impersonating the Service Account:
```sh
gcloud auth application-default login \
    --project="mathews-recurring-revenue-dev" \
    --impersonate-service-account="terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com" \
    --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive"
```
