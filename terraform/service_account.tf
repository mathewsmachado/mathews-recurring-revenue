resource "google_service_account" "dbt_core_service_account" {
  account_id   = "dbt-core-service-account"
  display_name = "Mathews Recurring Revenue dbt_core Service Account"
}

resource "google_project_iam_member" "dbt_core_service_account_bigquery_job_user_role" {
  project = var.mathews_recurring_revenue_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.dbt_core_service_account.email}"
}

resource "google_bigquery_dataset_access" "dbt_core_service_account_bigquery_dataset_reader_role" {
  dataset_id    = google_bigquery_dataset.google_sheets_raw_dataset.dataset_id
  role          = "READER"
  user_by_email = google_service_account.dbt_core_service_account.email
}

output "dbt_core_service_account_email" {
  value       = google_service_account.dbt_core_service_account.email
  description = "Mathews Recurring Revenue dbt_core Service Account email"
}
