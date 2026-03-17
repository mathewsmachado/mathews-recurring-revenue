variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "services" {
  description = "Set of GCP API service names to enable"
  type        = set(string)
}
