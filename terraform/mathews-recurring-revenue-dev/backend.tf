terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }

  required_version = "~> 1.12.2"

  backend "gcs" {
    bucket                      = "mathews-recurring-revenue-dev-terraform-bucket"
    prefix                      = "state"
    impersonate_service_account = "terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com"
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.project_region
  impersonate_service_account = "terraform@mathews-recurring-revenue-dev.iam.gserviceaccount.com"
}
