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

variable "logs_group_arn" {
  type        = string
  description = "log group to which CloudTrail logs will be delivered. should be identical to the management trail"
}

variable "logs_role_arn" {
  type        = string
  description = "Role for the CloudWatch Logs endpoint to assume to write to a user’s log group. Should be identical to the management trail"
}

locals {
  cloudtrail_name = "${var.resource_prefix}-${var.cloudtrail_name}"
}
