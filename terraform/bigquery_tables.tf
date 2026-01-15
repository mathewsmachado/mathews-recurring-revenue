resource "google_bigquery_table" "google_sheets__incomes" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.stg.dataset_id
  table_id            = "google_sheets__incomes"
  deletion_protection = false

  external_data_configuration {
    source_format = "GOOGLE_SHEETS"
    source_uris   = ["https://docs.google.com/spreadsheets/d/1BAdR_wHcAb2o7WAIBK36hdH-yTRt7HG8Vt-RcZFkBik"]

    google_sheets_options {
      range             = "Incomes"
      skip_leading_rows = 1
    }

    autodetect = false
    schema     = <<EOF
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
