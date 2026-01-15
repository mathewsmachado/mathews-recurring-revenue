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
