variable "resource_prefix" {
  description = "The prefix that will be appended to name of all the resources created"
  type        = string
  default     = "kscope"
}

variable "aws_iam_user" {
  type        = string
  description = "The name of the IAM user whose credentials are used by Kaleidoscope's aws crawler to crawl resoures. There is only one policy that we attach to this user, the AWS managed read only policy that allows this user to read any resource."
  default     = "crawl-user"
}

variable "cloudtrail_name" {
  type        = string
  description = "The name of the cloudtrail that is used by Kaleidoscope's aws crawler to track the events happening in your account. For more information on the way this trail is configured, see README"
  default     = "trail"
}

variable "bucket_name" {
  type        = string
  description = "The name of the s3 bucket that is used by cloudtrail to store its log file. Please note that the eventual name of this resoruce is {resource_prefix}-{bucke_name} and it has to be globally unique."
}

variable "aws_sqs_queue" {
  description = "The name of the aws sqs queue that subscribes to the sns topic. AWS's aws crawler polls this queue to get latest event log files. For more info see README"
  type        = string
  default     = "trail-queue"
}

variable "create_trail" {
  type        = bool
  default     = false
  description = "Whether to provision a cloudtrail trail. If this is false, it assumes you are using an Organization level trail in the management account"
}

locals {
  prefix          = var.resource_prefix
  cloudtrail_name = "${local.prefix}-${var.cloudtrail_name}"
  aws_s3_bucket   = "${local.prefix}-${var.bucket_name}"
  aws_iam_user    = "${local.prefix}-${var.aws_iam_user}"
  aws_sqs_queue   = "${local.prefix}-${var.aws_sqs_queue}"
}
