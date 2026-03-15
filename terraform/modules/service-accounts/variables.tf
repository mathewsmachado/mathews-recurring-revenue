variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "account_id" {
  description = "Service account ID"
  type        = string
}

variable "display_name" {
  description = "Service account display name"
  type        = string
}

variable "description" {
  description = "Service account description"
  type        = string
}

variable "roles" {
  description = "Set of IAM roles to grant to the service account"
  type        = set(string)
}

variable "impersonation_members" {
  description = "Set of members who can impersonate this service account"
  type        = set(string)
  default     = []
}

variable "workload_identity_members" {
  description = "Set of Workload Identity members who can impersonate this service account"
  type        = set(string)
  default     = []
}
