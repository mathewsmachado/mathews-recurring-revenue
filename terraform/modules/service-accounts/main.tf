resource "google_service_account" "main" {
  project                      = var.project_id
  account_id                   = var.account_id
  display_name                 = var.display_name
  description                  = var.description
  create_ignore_already_exists = true
  disabled                     = false
}

resource "google_project_iam_member" "main" {
  for_each = var.roles

  project = var.project_id
  member  = google_service_account.main.member
  role    = each.value
}

resource "google_service_account_iam_member" "main" {
  for_each = var.impersonation_members

  service_account_id = google_service_account.main.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}

resource "google_service_account_iam_member" "workload_identity" {
  for_each = var.workload_identity_members

  service_account_id = google_service_account.main.name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value
}
