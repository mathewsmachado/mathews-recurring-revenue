resource "google_service_account" "dbt_core_service_account" {
  account_id   = "dbt-core-service-account"
  display_name = "Mathews Recurring Revenue dbt_core Service Account"
}

resource "google_project_iam_member" "dbt_core_service_account_bigquery_user_role" {
  project = var.mathews_recurring_revenue_project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.dbt_core_service_account.email}"
}

resource "google_project_iam_member" "dbt_core_service_account_bigquery_data_editor_role" {
  project = var.mathews_recurring_revenue_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dbt_core_service_account.email}"
}

output "dbt_core_service_account_email" {
  value       = google_service_account.dbt_core_service_account.email
  description = "Mathews Recurring Revenue dbt_core Service Account email"
}
