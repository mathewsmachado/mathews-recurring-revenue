resource "google_bigquery_dataset" "stg" {
  project       = var.project_id
  location      = var.project_location
  dataset_id    = "stg"
  friendly_name = "Staging Dataset"
}
