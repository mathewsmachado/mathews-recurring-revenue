# gcloud auth application-default login \
#  --impersonate-service-account terraform@mathews-recurring-revenue.iam.gserviceaccount.com \
#  --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive"

# gcloud iam service-accounts add-iam-policy-binding \
#   terraform@mathews-recurring-revenue.iam.gserviceaccount.com \
#   --project="mathews-recurring-revenue" \
#   --member="user:mathews.machadoamorim@gmail.com" \
#   --role="roles/iam.serviceAccountTokenCreator"


resource "google_service_account" "terraform" {
  project                      = var.project_id
  description                  = "Terraform Service Account"
  account_id                   = "terraform"
  display_name                 = "terraform"
  create_ignore_already_exists = true
  disabled                     = false
}

resource "google_project_iam_member" "terraform_service_account_roles" {
  for_each = toset([
    "roles/bigquery.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin"
  ])

  project = var.project_id
  member  = google_service_account.terraform.member
  role    = each.value
}
