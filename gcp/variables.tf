variable "project_id" {
  description = "The GCP project ID to configure for Kaleidoscope crawling"
  type        = string
}

variable "service_account_name" {
  description = "The ID for the service account (will appear as <name>@<project>.iam.gserviceaccount.com)"
  type        = string
  default     = "kscope-crawl"
}
