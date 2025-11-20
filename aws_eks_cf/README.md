# Kaleidoscope AWS EKS Blueprint Configurator

This repository contains a CloudFormation template that sets up the required infrastructure in an AWS account to enable Kaleidoscope's Kubernetes Crawler to access and monitor Amazon EKS clusters.

## Overview

This CloudFormation template creates:
- An IAM role (`kaleidoscope-kubernetes-crawler-role`) that Kaleidoscope can assume to access your EKS clusters
- An IAM policy with the minimum required permissions to crawl EKS clusters and related resources
- Support for scoped access to specific EKS clusters or all clusters in the account

## Prerequisites

- AWS Account with permissions to create IAM roles and policies
- One or more EKS clusters deployed in your AWS account
- External ID and Kaleidoscope Account ID provided by Kaleidoscope

## Parameters

The CloudFormation template accepts the following parameters:

- **ExternalId** (Required): External ID for assuming the role, provided by Kaleidoscope
- **KaleidoscopeAccountId**: AWS Account ID of the Kaleidoscope platform (default: '123456789012')
- **EKSClusterNames**: Comma-separated list of EKS cluster names to grant access to (default: '*' for all clusters)

## Deployment

### Using AWS Console

1. Navigate to CloudFormation in your AWS Console
2. Click "Create Stack" and upload the `aws.yml` template
3. Provide the required parameters (ExternalId, KaleidoscopeAccountId, and optionally EKSClusterNames)
4. Review and create the stack

### Using AWS CLI

```bash
aws cloudformation create-stack \
  --stack-name kaleidoscope-eks-crawler \
  --template-body file://aws.yml \
  --parameters \
    ParameterKey=ExternalId,ParameterValue=<your-external-id> \
    ParameterKey=KaleidoscopeAccountId,ParameterValue=<kaleidoscope-account-id> \
    ParameterKey=EKSClusterNames,ParameterValue=<cluster-1,cluster-2> \
  --capabilities CAPABILITY_NAMED_IAM
```

## Post-Deployment Configuration

After deploying the CloudFormation stack, you need to update your EKS cluster's `aws-auth` ConfigMap to grant the IAM role access to the Kubernetes API:

1. Get the Role ARN from the CloudFormation stack outputs
2. Update the aws-auth ConfigMap:

```bash
kubectl edit configmap aws-auth -n kube-system
```

3. Add the following entry under `mapRoles`:

```yaml
- rolearn: <role-arn-from-stack-output>
  username: kaleidoscope-crawler
  groups:
    - system:masters
```

## Outputs

The stack provides the following outputs:

- **RoleArn**: ARN of the IAM role for Kaleidoscope Kubernetes Crawler
- **RoleName**: Name of the IAM role
- **PolicyArn**: ARN of the IAM policy
- **ConfigurationInstructions**: Detailed instructions for configuring the Kubernetes crawler

## Permissions Granted

The IAM policy grants the following permissions:

- **EKS**: Read access to clusters, node groups, addons, and Fargate profiles
- **EC2**: Read access to instances, security groups, subnets, VPCs, volumes, and network interfaces
- **IAM**: Read access to roles and policies
- **CloudWatch Logs**: Read access to EKS-related log groups

Customer facing docs here: https://docs.k6scope.com/hub/blueprints/kubernetes
