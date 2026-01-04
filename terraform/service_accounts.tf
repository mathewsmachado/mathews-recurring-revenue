resource "google_service_account" "dbt_project" {
  account_id   = "dbt-project"
  display_name = "dbt_project Service Account"
}

resource "google_project_iam_member" "dbt_project_bigquery_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.dbt_project.email}"
}

resource "google_project_iam_member" "dbt_project_bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dbt_project.email}"
}
