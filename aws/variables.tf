variable "bucket_name" {
  type        = string
  description = "The name of the s3 bucket that is used by cloudtrail to store its log file. Please note that the eventual name of this resoruce is {resource_prefix}-{bucke_name} and it has to be globally unique."
}
