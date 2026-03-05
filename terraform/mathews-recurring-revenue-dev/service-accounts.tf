# DBT Project
resource "google_service_account" "dbt_project" {
  project                      = var.project_id
  account_id                   = "dbt-project"
  display_name                 = "dbt-project"
  description                  = "DBT Project Service Account"
  create_ignore_already_exists = true
  disabled                     = false
}

resource "google_project_iam_member" "dbt_project" {
  for_each = toset([
    "roles/bigquery.user",
    "roles/bigquery.dataEditor"
  ])

  project = var.project_id
  member  = google_service_account.dbt_project.member
  role    = each.value
}

resource "google_service_account_iam_member" "dbt_project_impersonation" {
  for_each = toset(["user:mathews.machadoamorim@gmail.com"])

  service_account_id = google_service_account.dbt_project.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}
