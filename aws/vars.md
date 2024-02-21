<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | The access key that will be used to create resources. It needs to have create permissions for S3, Cloudtrail, EventBridge, SQS, and IAM | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"us-east-2"` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | The secret key associated with the access key. | `string` | n/a | yes |
| <a name="input_cloudtrail_bucket_name"></a> [cloudtrail\_bucket\_name](#input\_cloudtrail\_bucket\_name) | The name of the s3 bucket that is used by cloudtrail to store its log file. Please note that the eventual name of this resource is {resource\_prefix}-{bucket\_name} and it has to be globally unique. The default for this is empty. Cloudtrail will only be created when a value for this variable is set. | `string` | `""` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix that will be appended to name of all the resources created | `string` | `"kscope"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_accessKey"></a> [accessKey](#output\_accessKey) | Access Key to be used for Kaleidoscope data crawl |
| <a name="output_secretKey"></a> [secretKey](#output\_secretKey) | Secret Key to be used for Kaleidoscope data crawl |
| <a name="output_sqsURL"></a> [sqsURL](#output\_sqsURL) | SQS URL to be used for Kaleidoscope event crawl |
<!-- END_TF_DOCS -->