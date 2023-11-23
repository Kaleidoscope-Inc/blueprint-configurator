variable "bucket_name" {
  type        = string
  description = "The name of the s3 bucket that is used by cloudtrail to store its log file. Please note that the eventual name of this resoruce is {resource_prefix}-{bucke_name} and it has to be globally unique."
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

variable "create_trail" {
  type        = bool
  default     = false
  description = "Whether to provision a cloudtrail trail. If this is false, it assumes you are using an Organization level trail in the management account"
}
