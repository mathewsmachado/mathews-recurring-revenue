resource "google_bigquery_dataset" "main" {
  project                    = var.project_id
  location                   = var.location
  dataset_id                 = var.dataset_id
  friendly_name              = var.friendly_name
  delete_contents_on_destroy = var.delete_contents_on_destroy
}

resource "google_bigquery_table" "main" {
  for_each = var.google_sheets_tables

  project                      = var.project_id
  dataset_id                   = google_bigquery_dataset.main.dataset_id
  table_id                     = each.value.table_id
  deletion_protection          = false
  ignore_auto_generated_schema = false

  external_data_configuration {
    source_format = "GOOGLE_SHEETS"
    source_uris   = [each.value.source_uri]

    google_sheets_options {
      range             = each.value.range
      skip_leading_rows = each.value.skip_leading_rows
    }

    compression = "NONE"
    autodetect  = false
    schema      = each.value.schema_json
  }
}
