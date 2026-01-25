resource "google_bigquery_dataset" "raw" {
  project                    = var.project_id
  location                   = var.project_location
  dataset_id                 = "raw"
  friendly_name              = "Raw Dataset"
  delete_contents_on_destroy = false

  inexistent_key {
    true
  }
}

# Remember to share the spreadsheet with DBT's Project Service Account
resource "google_bigquery_table" "google_sheets__incomes" {
  project                      = var.project_id
  dataset_id                   = google_bigquery_dataset.raw.dataset_id
  table_id                     = "google_sheets__incomes"
  deletion_protection          = false
  ignore_auto_generated_schema = false

  external_data_configuration {
    source_format = "GOOGLE_SHEETS"
    source_uris   = ["https://docs.google.com/spreadsheets/d/1BAdR_wHcAb2o7WAIBK36hdH-yTRt7HG8Vt-RcZFkBik"]

    google_sheets_options {
      range             = "Incomes"
      skip_leading_rows = 1
    }

    compression = "NONE"
    autodetect  = false
    schema      = <<EOF
      [
        { "name": "tran_date", "type": "STRING" },
        { "name": "tran_payer", "type": "STRING" },
        { "name": "tran_payee", "type": "STRING" },
        { "name": "tran_payer_payee_relation", "type": "STRING" },
        { "name": "tran_category", "type": "STRING" },
        { "name": "tran_detail", "type": "STRING" },
        { "name": "tran_currency", "type": "STRING" },
        { "name": "tran_net", "type": "STRING" },
        { "name": "tran_gross", "type": "STRING" },
        { "name": "tran_gross_delta_category", "type": "STRING" },
        { "name": "tran_gross_delta_detail", "type": "STRING" },
        { "name": "accounting_month", "type": "STRING" },
        { "name": "accounting_status", "type": "STRING" }
      ]
    EOF
  }
}
