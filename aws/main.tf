terraform {
  required_version = ">=1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }
}


provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  default_tags {
    tags = {
      Org = "kaleidoscope"
    }
  }

}

module "kscope_crawl" {
  source                 = "./kscope_crawl"
  cloudtrail_bucket_name = var.cloudtrail_bucket_name
  resource_prefix        = var.resource_prefix
  environment = var.environment
}


output "accessKey" {
  value = module.kscope_crawl.accessKey
}

output "secretKey" {
  value     = module.kscope_crawl.secretKey
  sensitive = true
}

output "sqsURL" {
  value = module.kscope_crawl.sqsURL
}

