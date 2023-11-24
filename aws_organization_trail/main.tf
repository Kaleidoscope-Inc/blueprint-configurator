terraform {
  required_version = ">=1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.26.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

resource "aws_cloudtrail" "data" {
  name = local.cloudtrail_name

  s3_bucket_name                = var.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  cloud_watch_logs_group_arn    = var.logs_group_arn
  cloud_watch_logs_role_arn     = var.logs_role_arn
  enable_log_file_validation    = true
  enable_logging                = true


  # enables all data events.
  advanced_event_selector {
    name = "Data Event Selector"
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
  }
}
