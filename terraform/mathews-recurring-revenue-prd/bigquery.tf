resource "google_bigquery_dataset" "raw" {
  project       = var.project_id
  location      = var.project_location
  dataset_id    = "raw"
  friendly_name = "Raw Dataset"
  delete_contents_on_destroy = false
}
