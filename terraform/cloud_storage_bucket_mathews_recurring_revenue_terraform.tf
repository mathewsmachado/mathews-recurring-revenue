resource "google_storage_bucket" "mathews_recurring_revenue_terraform_bucket" {
  project                     = var.project_id
  location                    = var.project_location
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
