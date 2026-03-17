variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "BigQuery dataset location"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
}

variable "friendly_name" {
  description = "BigQuery dataset friendly name"
  type        = string
}

variable "delete_contents_on_destroy" {
  description = "Whether to delete dataset contents on destroy"
  type        = bool
  default     = false
}

variable "google_sheets_tables" {
  description = "Map of Google Sheets-backed external tables to create"
  type = map(object({
    table_id          = string
    source_uri        = string
    range             = string
    skip_leading_rows = number
    schema_json       = string
  }))
}
