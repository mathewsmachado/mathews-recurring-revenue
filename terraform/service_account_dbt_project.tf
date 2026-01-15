resource "google_service_account" "dbt_project" {
  project                      = var.project_id
  description                  = "DBT Project Service Account"
  account_id                   = "dbt-project"
  display_name                 = "dbt-project"
  create_ignore_already_exists = true
  disabled                     = false
}

resource "google_project_iam_member" "dbt_project_service_account_roles" {
  for_each = toset([
    "roles/bigquery.user",
    "roles/bigquery.dataEditor"
  ])

  project = var.project_id
  member  = google_service_account.terraform.member
  role    = each.value
}
