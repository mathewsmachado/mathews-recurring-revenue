terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }

  required_version = "~> 1.12.2"

  backend "gcs" {
    bucket                      = "mathews-recurring-revenue-prd-terraform-bucket"
    prefix                      = "state"
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.project_region
}
