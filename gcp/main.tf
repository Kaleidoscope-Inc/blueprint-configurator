terraform {
  # No backend block — state is managed by Google Cloud Infrastructure Manager
  required_version = "1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

# Service account for Kaleidoscope crawling
resource "google_service_account" "kscope_crawl" {
  account_id   = var.service_account_name
  display_name = "Kaleidoscope Crawl Service Account"
  description  = "Read-only service account used by Kaleidoscope to crawl GCP resources"
}

# Query the Service Usage API to discover which APIs are enabled in the project
data "google_client_config" "current" {}

data "http" "enabled_services" {
  url = "https://serviceusage.googleapis.com/v1/projects/${var.project_id}/services?filter=state:ENABLED&pageSize=200"
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
}

# Map each GCP API to the IAM roles it requires
locals {
  enabled_apis = toset([
    for svc in jsondecode(data.http.enabled_services.response_body).services : svc.config.name
  ])

  core_roles = [
    "roles/viewer",
    "roles/iam.securityReviewer",
  ]

  service_api_roles = {
    "compute.googleapis.com"              = ["roles/compute.securityAdmin", "roles/compute.viewer"]
    "container.googleapis.com"            = ["roles/container.viewer"]
    "sqladmin.googleapis.com"             = ["roles/cloudsql.viewer"]
    "cloudfunctions.googleapis.com"       = ["roles/cloudfunctions.viewer"]
    "run.googleapis.com"                  = ["roles/run.viewer"]
    "redis.googleapis.com"                = ["roles/redis.viewer"]
    "firebase.googleapis.com"             = ["roles/firebase.viewer"]
    "artifactregistry.googleapis.com"     = ["roles/artifactregistry.reader"]
    "cloudkms.googleapis.com"             = ["roles/cloudkms.viewer"]
    "secretmanager.googleapis.com"        = ["roles/secretmanager.viewer"]
    "bigquery.googleapis.com"             = ["roles/bigquery.dataViewer"]
    "accesscontextmanager.googleapis.com" = ["roles/accesscontextmanager.policyReader"]
    "cloudbuild.googleapis.com"           = ["roles/cloudbuild.builds.viewer"]
    "datastore.googleapis.com"            = ["roles/datastore.viewer"]
    "file.googleapis.com"                 = ["roles/file.viewer"]
    "apigateway.googleapis.com"           = ["roles/apigateway.viewer"]
    "aiplatform.googleapis.com"           = ["roles/aiplatform.viewer"]
    "eventarc.googleapis.com"             = ["roles/eventarc.viewer"]
    "workflows.googleapis.com"            = ["roles/workflows.viewer"]
    "dataproc.googleapis.com"             = ["roles/dataproc.viewer"]
    "composer.googleapis.com"             = ["roles/composer.viewer"]
    "spanner.googleapis.com"              = ["roles/spanner.viewer"]
    "cloudtasks.googleapis.com"           = ["roles/cloudtasks.viewer"]
    "deploymentmanager.googleapis.com"    = ["roles/deploymentmanager.viewer"]
    "config.googleapis.com"               = ["roles/config.viewer"]
    "alloydb.googleapis.com"              = ["roles/alloydb.viewer"]
    "bigtableadmin.googleapis.com"        = ["roles/bigtable.viewer"]
    "datacatalog.googleapis.com"          = ["roles/datacatalog.viewer"]
    "dataflow.googleapis.com"             = ["roles/dataflow.viewer"]
  }

  enabled_service_roles = flatten([
    for api, roles in local.service_api_roles : roles
    if contains(local.enabled_apis, api)
  ])

  required_roles = concat(local.core_roles, local.enabled_service_roles)
}

resource "google_project_iam_member" "kscope_crawl_roles" {
  for_each = toset(local.required_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.kscope_crawl.email}"
}

# Generate a service account key for Kaleidoscope configuration
resource "google_service_account_key" "kscope_crawl" {
  service_account_id = google_service_account.kscope_crawl.name
}
