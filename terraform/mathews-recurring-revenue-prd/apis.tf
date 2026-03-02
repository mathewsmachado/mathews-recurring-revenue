locals {
  apis = [
    "run.googleapis.com"
  ]
}

resource "google_project_service" "api" {
  for_each = toset(local.apis)
  project  = var.project_id
  service  = each.value
}
