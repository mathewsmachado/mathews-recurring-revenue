output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.main.email
}

output "service_account_member" {
  description = "IAM member string of the service account"
  value       = google_service_account.main.member
}
