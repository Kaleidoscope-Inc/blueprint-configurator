variable "cloudtrail_bucket_name" {
  type        = string
  description = "The name of the s3 bucket that is used by cloudtrail to store its log file. Please note that the eventual name of this resource is {resource_prefix}-{bucket_name} and it has to be globally unique. The default for this is empty. Cloudtrail will only be created when a value for this variable is set."
  default     = ""
}

variable "resource_prefix" {
  description = "The prefix that will be appended to name of all the resources created"
  type        = string
  default     = "kscope"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_access_key" {
  type        = string
  description = "The access key that will be used to create resources. It needs to have create permissions for S3, Cloudtrail, EventBridge, SQS, and IAM"
}

variable "aws_secret_key" {
  type        = string
  description = "The secret key associated with the access key."
}

variable "environment" {
  description = "The name of the environment (e.g., dev, staging, prod)"
  type        = string
}
