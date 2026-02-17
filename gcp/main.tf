terraform {
  # No backend block — state is managed by Google Cloud Infrastructure Manager
  required_version = "1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
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

# All required IAM role bindings — read-only access across GCP services
locals {
  required_roles = [
    "roles/viewer",                              # Compute, DNS, GKE, Storage, Cloud Functions, Cloud Run, Pub/Sub, Logging, Monitoring, Artifact Registry, Memorystore, Firebase, VPC, NAT, LB, Cloud SQL, Endpoints
    "roles/cloudkms.viewer",                     # Cloud KMS (key rings, crypto keys, key versions)
    "roles/secretmanager.viewer",                # Secret Manager (secret metadata — does not expose secret values)
    "roles/iam.securityReviewer",                # IAM policies, Cloud Audit Logs, Identity Platform
    "roles/bigquery.dataViewer",                 # BigQuery datasets and tables (read-only metadata and schema)
    "roles/compute.securityAdmin",               # Cloud Armor security policies and rules
    "roles/accesscontextmanager.policyReader",   # VPC Service Controls access policies, service perimeters
    "roles/cloudbuild.builds.viewer",            # Cloud Build triggers, worker pools, builds
    "roles/datastore.viewer",                    # Firestore databases, indexes, collection groups
    "roles/file.viewer",                         # Cloud Filestore instances, snapshots, backups
    "roles/apigateway.viewer",                   # API Gateway APIs, gateways, configurations
    "roles/aiplatform.viewer",                   # Vertex AI models, endpoints, training pipelines
    "roles/eventarc.viewer",                     # Eventarc triggers, channels, channel connections
    "roles/workflows.viewer",                    # Cloud Workflows definitions and executions
    "roles/dataproc.viewer",                     # Dataproc clusters, jobs, workflow templates
    "roles/composer.viewer",                     # Cloud Composer environments and configurations
    "roles/spanner.viewer",                      # Cloud Spanner instances and databases
    "roles/cloudtasks.viewer",                   # Cloud Tasks queues and task metadata
    "roles/compute.viewer",                      # Cloud CDN backend services and cache policies
    "roles/deploymentmanager.viewer",            # Deployment Manager deployments and resources
  ]
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
