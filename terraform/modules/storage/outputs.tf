output "bucket_name" {
  description = "Name of the storage bucket"
  value       = google_storage_bucket.main.name
}

output "bucket_url" {
  description = "URL of the storage bucket"
  value       = google_storage_bucket.main.url
}
