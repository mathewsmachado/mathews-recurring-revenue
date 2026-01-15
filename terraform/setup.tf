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

resource "google_service_account" "terraform" {
  account_id                   = "terraform"
  create_ignore_already_exists = null
  description                  = "Terraform Service Account"
  disabled                     = false
  display_name                 = "terraform"
  project                      = "mathews-recurring-revenue"
}

resource "google_project_iam_member" "iam_service_account_admin" {
  member  = "serviceAccount:terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
  project = "mathews-recurring-revenue"
  role    = "roles/iam.serviceAccountAdmin"
}

resource "google_project_iam_member" "resourcemanager_project_iam_admin" {
  member  = "serviceAccount:terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
  project = "mathews-recurring-revenue"
  role    = "roles/resourcemanager.projectIamAdmin"
}

resource "google_project_iam_member" "storage_admin" {
  member  = "serviceAccount:terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
  project = "mathews-recurring-revenue"
  role    = "roles/storage.admin"
}

resource "google_project_iam_member" "bigquery_admin" {
  member  = "serviceAccount:terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
  project = "mathews-recurring-revenue"
  role    = "roles/bigquery.admin"
}

resource "google_project_iam_member" "iam_service_account_token_creator" {
  member  = "serviceAccount:terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
  project = "mathews-recurring-revenue"
  role    = "roles/iam.serviceAccountTokenCreator"
}

resource "google_project_iam_member" "storage_object_admin" {
  member  = "serviceAccount:terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
  project = "mathews-recurring-revenue"
  role    = "roles/storage.objectAdmin"
}

resource "google_project_iam_member" "serviceusage_service_usage_admin" {
  member  = "serviceAccount:terraform@mathews-recurring-revenue.iam.gserviceaccount.com"
  project = "mathews-recurring-revenue"
  role    = "roles/serviceusage.serviceUsageAdmin"
}

resource "google_storage_bucket" "mathews_recurring_revenue_terraform_bucket" {
  default_event_based_hold    = false
  enable_object_retention     = false
  force_destroy               = false
  labels                      = {}
  location                    = "US"
  name                        = "mathews-recurring-revenue-terraform-bucket"
  project                     = "mathews-recurring-revenue"
  public_access_prevention    = "enforced"
  requester_pays              = false
  rpo                         = "DEFAULT"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  hierarchical_namespace {
    enabled = false
  }

  soft_delete_policy {
    retention_duration_seconds = 604800
  }
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
