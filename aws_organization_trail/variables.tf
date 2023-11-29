variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "The region the resources are to be provisioned at"
}

variable "cloudtrail_name" {
  type    = string
  default = "data-trail"
}

variable "resource_prefix" {
  type    = string
  default = "kscope"
}

variable "s3_bucket_name" {
  type        = string
  description = "where the trail will save it's log files. should be identical to the management trail"
}

variable "s3_key_prefix" {
  type        = string
  description = "S3 key prefix that follows the name of the bucket you have designated for log file delivery"
}

variable "logs_group_arn" {
  type        = string
  description = "log group to which CloudTrail logs will be delivered. should be identical to the management trail"
}

variable "logs_role_arn" {
  type        = string
  description = "Role for the CloudWatch Logs endpoint to assume to write to a user’s log group. Should be identical to the management trail"
}

variable "sns_topic_name" {
  type        = string
  description = "Name of the Amazon SNS topic defined for notification of log file delivery"
}

locals {
  cloudtrail_name = "${var.resource_prefix}-${var.cloudtrail_name}"
}
