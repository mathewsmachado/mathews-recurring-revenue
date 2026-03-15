resource "google_artifact_registry_repository" "main" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format

  cleanup_policies {
    id     = "delete-old-images"
    action = "DELETE"

    condition {
      tag_state = "ANY"
    }
  }

  cleanup_policies {
    id     = "keep-last-n-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = var.cleanup_keep_count
    }
  }
}
