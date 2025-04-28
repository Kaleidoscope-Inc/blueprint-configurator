# Kaleidoscope AWS Blueprint Configurator

This repository contains a CloudFormation template that sets up the required infrastructure in an AWS account to enable Kaleidoscope's AWS Blueprint to crawl and monitor resources.

## Overview

The CloudFormation template provisions:

1. **Data Crawl Infrastructure**:
   - IAM user with ReadOnlyAccess policy
   - Access keys for secure authentication

2. **Event Crawl Infrastructure**:
   - SQS queue for event collection
   - EventBridge rule to capture CloudTrail events
   - Optional CloudTrail configuration

## Deployment Options

### Option 1: Quick Deploy

Click the link below to quickly deploy this template to your AWS account:

[<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png" alt="Launch Stack">](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/quickcreate?templateURL=https://kaleidoscope-blueprint-configurator.s3.amazonaws.com/aws/aws-latest.yml&param_ResourcePrefix=kscope&stackName=kaleidoscope-blueprint)

### Option 2: Manual Deployment

1. Download the CloudFormation template (`aws.yml`) from this repository
2. Sign in to the AWS Management Console
3. Navigate to CloudFormation
4. Create a new stack and upload the template
5. Enter the required parameters

## Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| ResourcePrefix | Prefix appended to created resources | kscope |
| CloudTrailBucketName | S3 bucket name for CloudTrail logs (leave empty to use existing org-level CloudTrail) | '' |

## Infrastructure Created

### Always Created
- IAM user with ReadOnlyAccess
- IAM access key for the user
- SQS queue for event collection
- EventBridge rule targeting the SQS queue

### Created Only When CloudTrailBucketName Is Provided
- S3 bucket for CloudTrail logs
- CloudTrail configuration capturing both management and data events

## Usage Scenarios

### Scenario 1: Organization with Existing CloudTrail
Leave the `CloudTrailBucketName` parameter empty to use your existing organizational CloudTrail. The template will only create the event collection infrastructure.

### Scenario 2: Account Without Organizational CloudTrail
Provide a value for `CloudTrailBucketName` to create a new tenant-specific CloudTrail that captures both management and data events.

## Outputs

After deployment, the stack provides the following outputs:

- **AccessKeySecretName**: The Secrets Manager secret name containing the access key for data crawl operations
- **SecretKeySecretName**: The Secrets Manager secret name containing the secret key 
- **SQSURL**: The endpoint for consuming event data

To retrieve the actual credentials, use the AWS CLI:

```bash
# Get the access key
aws secretsmanager get-secret-value --secret-id "/kscope/crawler/access-key" --query SecretString --output text

# Get the secret key (requires appropriate permissions)
aws secretsmanager get-secret-value --secret-id "/kscope/crawler/secret-key" --query SecretString --output text
```

## Required Permissions

### Deployment Permissions
To deploy this template, you need permissions to create:
- IAM users and policies
- SQS queues
- EventBridge rules
- Secrets Manager (for storing credentials)
- S3 buckets (if creating CloudTrail)
- CloudTrail (if creating a new trail)