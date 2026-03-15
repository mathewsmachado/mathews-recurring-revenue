terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }

  required_version = "1.14.5"

  backend "gcs" {
    bucket = "mathews-mrr-prd-terraform-bucket"
    prefix = "state"
  }
}

provider "google" {
  project = var.project_id
  region  = local.shared.project_region
}

locals {
  shared     = jsondecode(file("../../shared/config.json"))
  wif_member = "principalSet://iam.googleapis.com/projects/489693200516/locations/global/workloadIdentityPools/github/attribute.repository/mathews-recurring-revenue"
}
