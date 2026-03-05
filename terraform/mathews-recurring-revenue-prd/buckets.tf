resource "google_storage_bucket" "dbt-project-bucket" {
  project                  = var.project_id
  location                 = var.project_location
  name                     = "${var.project_id}-dbt-project-bucket"
  storage_class            = "STANDARD"
  public_access_prevention = "enforced"
}

# Allow staging GitHub Service Account to download artifacts from production bucket for deploy-dbt-project-staging
resource "google_storage_bucket_iam_member" "dbt-project-bucket-stg-github-sa" {
  bucket = google_storage_bucket.dbt-project-bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:github@mathews-recurring-revenue-stg.iam.gserviceaccount.com"
}
