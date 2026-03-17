variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Repository location"
  type        = string
}

variable "repository_id" {
  description = "Artifact Registry repository ID"
  type        = string
}

variable "description" {
  description = "Repository description"
  type        = string
}

variable "format" {
  description = "Repository format"
  type        = string
  default     = "DOCKER"
}

variable "cleanup_keep_count" {
  description = "Number of most recent image versions to keep"
  type        = number
  default     = 3
}
