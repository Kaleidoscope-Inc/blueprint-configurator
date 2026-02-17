output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "client_email" {
  description = "Service account email — use as 'Client Email' in Kaleidoscope"
  value       = google_service_account.kscope_crawl.email
}

output "client_id" {
  description = "Service account unique ID — use as 'Client ID' in Kaleidoscope"
  value       = google_service_account.kscope_crawl.unique_id
}

output "private_key_id" {
  description = "Private key ID — use as 'Private Key ID' in Kaleidoscope"
  value       = google_service_account_key.kscope_crawl.private_key
  sensitive   = true
}

output "service_account_key_json" {
  description = "Full service account key JSON (base64 encoded). Decode with: terraform output -raw service_account_key_json | base64 -d"
  value       = google_service_account_key.kscope_crawl.private_key
  sensitive   = true
}
