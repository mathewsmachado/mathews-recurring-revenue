resource "google_storage_bucket" "dbt-project-bucket" {
  project                  = var.project_id
  location                 = var.project_location
  name                     = "${var.project_id}-dbt-project-bucket"
  storage_class            = "STANDARD"
  public_access_prevention = "enforced"
}
