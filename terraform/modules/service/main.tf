resource "google_project_service" "main" {
  for_each = var.services

  project = var.project_id
  service = each.value
}
