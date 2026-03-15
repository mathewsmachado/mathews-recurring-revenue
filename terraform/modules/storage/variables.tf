variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Bucket location"
  type        = string
}

variable "name" {
  description = "Bucket name"
  type        = string
}

variable "storage_class" {
  description = "Bucket storage class"
  type        = string
  default     = "STANDARD"
}

variable "public_access_prevention" {
  description = "Public access prevention setting"
  type        = string
  default     = "enforced"
}

variable "iam_members" {
  description = "List of IAM member bindings for the bucket"
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}
