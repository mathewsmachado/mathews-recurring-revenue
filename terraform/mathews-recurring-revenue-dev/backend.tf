/*
Terraform needs the following steps to work:

    1. Create a GCP project

    2. Create a Service Account for Terraform:
        ```sh
        gcloud iam service-accounts create terraform \
            --project="mathews-recurring-revenue-dev" \
            --display-name="Terraform Service Account"
        ```

    3. Assign the following roles to Terraform's Service Account:
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

    4. Enable Credentials API:
        ```sh
        gcloud services enable iamcredentials.googleapis.com \
            --project mathews-recurring-revenue-dev
        ```

    5. Authorize your personal user to impersonate Terraform's Service Account:
        ```sh
        gcloud iam service-accounts add-iam-policy-binding terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com \
            --project="mathews-recurring-revenue-dev" \
            --member="user:mathews.machadoamorim@gmail.com" \
            --role="roles/iam.serviceAccountTokenCreator"
        ```

    6. Reauthenticate, impersonating Terraform's Service Account:
        ```sh
        gcloud auth application-default login \
            --project="mathews-recurring-revenue-dev" \
            --impersonate-service-account="terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com" \
            --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive"
        ```

    7. Create a bucket to store Terraform's remote state
        ```sh
        gcloud storage buckets create gs://mathews-recurring-revenue-dev-terraform-bucket \
            --project=mathews-recurring-revenue-dev \
            --location=us-central1 \
            --uniform-bucket-level-access \
            --public-access-prevention \
            --soft-delete-duration=7d
        ```
*/

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }

  required_version = "~> 1.12.2"

  backend "gcs" {
    impersonate_service_account = "terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com"
    bucket                      = "mathews-recurring-revenue-dev-terraform-bucket"
    prefix                      = "state"
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.project_region
  impersonate_service_account = "terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com"
}
