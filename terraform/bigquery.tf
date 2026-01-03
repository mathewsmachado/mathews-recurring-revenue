resource "google_bigquery_dataset" "google_sheets_raw_dataset" {
  project       = var.mathews_recurring_revenue_project_id
  location      = "US"
  dataset_id    = "google_sheets_raw"
  friendly_name = "google Sheets Raw"
}

resource "google_bigquery_table" "test_spreadsheet_table" {
  project    = var.mathews_recurring_revenue_project_id
  dataset_id = google_bigquery_dataset.google_sheets_raw_dataset.dataset_id
  table_id   = "test_spreadsheet"
  schema     = <<EOF
    [
      { "name": "id", "type": "STRING" },
      { "name": "name", "type": "STRING" },
      { "name": "age", "type": "STRING" },
      { "name": "role", "type": "STRING" }
    ]
  EOF

  external_data_configuration {
    source_format = "GOOGLE_SHEETS"
    source_uris   = ["https://docs.google.com/spreadsheets/d/17tFbgCxwtngdbqg-GXivLQE2nljTIYuA72023tP-NQo"]
    google_sheets_options {
      skip_leading_rows = 1
    }
    autodetect  = false
    compression = "GZIP"
  }

  deletion_protection = false
}