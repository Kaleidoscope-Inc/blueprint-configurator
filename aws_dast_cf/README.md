# AWS AI DAST CloudFormation Template

This CloudFormation template creates an IAM role with Bedrock invoke model permissions for Kaleidoscope AI DAST (AI-powered Dynamic Application Security Testing).

## Resources Created

- **IAM Role**: Cross-account role for AI DAST operations
- **External ID**: Auto-generated and stored in AWS Secrets Manager
- **Bedrock Permissions**: Model invocation capabilities

## Parameters

- `ResourcePrefix`: Prefix for all resource names (default: `kscope`)
- `TrustedAccountId`: Kaleidoscope AWS Account ID that can assume the AI DAST role

## Deployment

### Using AWS CLI

```bash
aws cloudformation create-stack \
  --stack-name kscope-ai-dast-stack \
  --template-body file://aws.yml \
  --parameters ParameterKey=TrustedAccountId,ParameterValue=YOUR_KALEIDOSCOPE_ACCOUNT_ID \
  --capabilities CAPABILITY_NAMED_IAM
```

### Using AWS Console

1. Navigate to CloudFormation in AWS Console
2. Click "Create Stack"
3. Upload the `aws.yml` template
4. Enter the required parameters:
   - `TrustedAccountId`: Kaleidoscope's AWS Account ID
   - `ResourcePrefix`: (optional) Custom prefix for resources
5. Acknowledge IAM resource creation
6. Click "Create Stack"

## Outputs

After deployment, the stack provides:

- **AIDASTRoleArn**: ARN of the IAM role to be assumed by Kaleidoscope
- **ExternalIdSecretName**: Secrets Manager secret containing the external ID

## Permissions Granted

The AI DAST role has the following Bedrock permissions:

- `bedrock:InvokeModel` - Invoke Bedrock models
- `bedrock:InvokeModelWithResponseStream` - Invoke models with streaming response

## Security

- **External ID**: Automatically generated 32-character alphanumeric string for secure cross-account access
- **Least Privilege**: Only grants specific Bedrock invoke permissions
- **Cross-Account Trust**: Role can only be assumed by the specified trusted account with the correct external ID

## Retrieving the External ID

To retrieve the external ID for Kaleidoscope to use:

```bash
aws secretsmanager get-secret-value \
  --secret-id /kscope/ai-dast/external-id \
  --query SecretString \
  --output text | jq -r '.externalId'
```

## Clean Up

To delete the stack and all resources:

```bash
aws cloudformation delete-stack --stack-name kscope-ai-dast-stack
```

Note: The Secrets Manager secret may need to be manually deleted after stack deletion.
