/*
Terraform needs the following steps to work:

    1. Create a GCP project

    2. Create a Service Account for GitHub per environment:
        ```sh
        gcloud iam service-accounts create github-actions \
            --project="mathews-recurring-revenue-stg" \
            --display-name="GitHub Actions Service Account"
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
                gcloud projects add-iam-policy-binding mathews-recurring-revenue-stg \
                    --member="serviceAccount:github-actions@mathews-recurring-revenue-stg.iam.gserviceaccount.com" \
                    --role="$role"; \
            done
        ```

    # 4. Enable Credentials API:
    #     ```sh
    #     gcloud services enable iamcredentials.googleapis.com \
    #         --project mathews-recurring-revenue-stg
    #     ```

    5. Allow the Workload Identity Pool to impersonate the Service Account
        ```sh
        gcloud iam service-accounts add-iam-policy-binding \
            "github-actions@mathews-recurring-revenue-stg.iam.gserviceaccount.com" \
            --project="mathews-recurring-revenue-stg" \
            --role="roles/iam.workloadIdentityUser" \
            --member="principalSet://iam.googleapis.com/projects/724228842720/locations/global/workloadIdentityPools/github/attribute.repository/mathewsmachado/mathews-recurring-revenue"
        ```

    7. Create a bucket to store Terraform's remote state
        ```sh
        gcloud storage buckets create gs://mathews-recurring-revenue-stg-terraform-bucket \
            --project=mathews-recurring-revenue-stg \
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
    # impersonate_service_account = "github-actions@mathews-recurring-revenue-stg.iam.gserviceaccount.com"
    bucket                      = "mathews-recurring-revenue-stg-terraform-bucket"
    prefix                      = "state"
  }
}

provider "google" {
  # impersonate_service_account = "github-actions@mathews-recurring-revenue-stg.iam.gserviceaccount.com"
  project                     = var.project_id
  region                      = var.project_region
}
