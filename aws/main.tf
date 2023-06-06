terraform {
  required_version = ">=1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }

  cloud {
    organization = "KaleidoscopeInc"
    workspaces {
      tags = ["crawl"]
    }
  }
}


provider "aws" {
  region = "us-east-2"
}

module "kscope_crawl" {
  source      = "./kscope_crawl"
  bucket_name = var.bucket_name
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

output "accountID" {
  value = module.kscope_crawl.accountID
}

