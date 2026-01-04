# gcloud auth application-default login \
#  --impersonate-service-account terraform@mathews-recurring-revenue.iam.gserviceaccount.com \
#  --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive"

# gcloud iam service-accounts add-iam-policy-binding \
#   terraform@mathews-recurring-revenue.iam.gserviceaccount.com \
#   --project="mathews-recurring-revenue" \
#   --member="user:mathews.machadoamorim@gmail.com" \
#   --role="roles/iam.serviceAccountTokenCreator"

provider "google" {
  project = var.project_id
  region  = var.project_region
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
    impersonate_service_account = "terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
    bucket                      = "mathews-recurring-revenue-terraform-bucket"
  }
}
