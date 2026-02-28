resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "dbt-project" {
  project       = var.project_id
  location      = var.project_region
  repository_id = "dbt-project"
  description   = "dbt Project Artifact Registry Repository"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry]

  cleanup_policies {
    id     = "delete-old-images"
    action = "DELETE"

    condition {
      tag_state = "ANY"
    }
  }

  cleanup_policies {
    id     = "keep-last-3-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = 3
    }
  }
}
