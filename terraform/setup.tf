# gcloud auth application-default login \
#  --impersonate-service-account terraform@mathews-recurring-revenue.iam.gserviceaccount.com \
#  --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive"

# gcloud iam service-accounts add-iam-policy-binding \
#   terraform@mathews-recurring-revenue.iam.gserviceaccount.com \
#   --project="mathews-recurring-revenue" \
#   --member="user:mathews.machadoamorim@gmail.com" \
#   --role="roles/iam.serviceAccountTokenCreator"

# Provider
provider "google" {
  project = var.project_id
  region  = var.project_region
}

# Terraform Service Account
resource "google_service_account" "terraform" {
  project                      = "mathews-recurring-revenue"
  description                  = "Terraform Service Account"
  account_id                   = "terraform"
  display_name                 = "terraform"
  create_ignore_already_exists = null
  disabled                     = false
}

# Terraform Service Account Roles
locals {
  roles = [
    "bigquery.admin",
    "iam.serviceAccountAdmin",
    "iam.serviceAccountTokenCreator",
    "resourcemanager.projectIamAdmin",
    "storage.admin",
    "storage.objectAdmin",
    "serviceusage.serviceUsageAdmin"
  ]
}

resource "google_project_iam_member" "terraform_service_account_roles" {
  for_each = toset(local.roles)

  project = var.project_id
  member  = "serviceAccount:${google_service_account.terraform.email}"
  role    = "roles/${each.value}"
}

# Terraform State Bucket
resource "google_storage_bucket" "mathews_recurring_revenue_terraform_bucket" {
  project                     = "mathews-recurring-revenue"
  location                    = "US"
  name                        = "mathews-recurring-revenue-terraform-bucket"
  storage_class               = "STANDARD"
  public_access_prevention    = "enforced"
  rpo                         = "DEFAULT"
  force_destroy               = false
  default_event_based_hold    = false
  enable_object_retention     = false
  requester_pays              = false
  uniform_bucket_level_access = true
  labels                      = {}

  hierarchical_namespace {
    enabled = false
  }

  soft_delete_policy {
    retention_duration_seconds = 604800
  }
}

# Terraform Block
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
