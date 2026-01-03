# gcloud iam service-accounts add-iam-policy-binding \
#   terraform-service-account@mathews-recurring-revenue.iam.gserviceaccount.com \
#   --project="mathews-recurring-revenue" \
#   --member="user:mathews.machadoamorim@gmail.com" \
#   --role="roles/iam.serviceAccountTokenCreator"

provider "google" {
  project = var.mathews_recurring_revenue_project_id
  region  = var.mathews_recurring_revenue_project_region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.46.0"
    }
  }

  required_version = "~> 1.12.2"

  backend "gcs" {
    impersonate_service_account = "terraform-service-account@mathews-recurring-revenue.iam.gserviceaccount.com"
    bucket                      = "mathews-recurring-revenue-terraform-bucket"
  }
}

import {
  to = google_service_account.terraform_service_account
  id = "projects/mathews-recurring-revenue/serviceAccounts/terraform-service-account@mathews-recurring-revenue.iam.gserviceaccount.com"
}

import {
  to = google_storage_bucket.mathews_recurring_revenue_terraform_bucket
  id = "mathews-recurring-revenue-terraform-bucket"
}
