

resource "aws_s3_bucket" "s3-bucket" {
  bucket        = local.aws_s3_bucket
  force_destroy = true
  acl           = "private"
}

resource "aws_s3_bucket_public_access_block" "aws-bucket-access-block" {
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket_policy.aws-bucket-policy
  ]
}


resource "aws_s3_bucket_policy" "aws-bucket-policy" {
  bucket = aws_s3_bucket.s3-bucket.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AWSCloudTrailAclCheck",
        Effect : "Allow",
        Principal : {
          Service : "cloudtrail.amazonaws.com"
        },
        Action : "s3:GetBucketAcl",
        Resource : [
          aws_s3_bucket.s3-bucket.arn
        ]
      },
      {
        Sid : "AWSCloudTrailWrite",
        Effect : "Allow",
        Principal : {
          Service : "cloudtrail.amazonaws.com"
        },
        Action : "s3:PutObject",
        Resource : [
          "${aws_s3_bucket.s3-bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        ]
        Condition : {
          StringEquals : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic" "sns-topic" {
  name = local.aws_sns_topic

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false,
      "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
      }
    }
  })
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn = aws_sns_topic.sns-topic.arn

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__default_statement_ID",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish",
          "SNS:Receive"
        ],
        "Resource" : "${aws_sns_topic.sns-topic.arn}",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceOwner" : "${data.aws_caller_identity.current.account_id}"
          }
        }
      },
      {
        "Sid" : "AWSCloudTrailSNSPolicy20150319",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "SNS:Publish",
        "Resource" : "${aws_sns_topic.sns-topic.arn}"
      }
    ]
  })
}

resource "aws_cloudtrail" "cloudtrail" {
  name = local.cloudtrail_name

  s3_bucket_name                = aws_s3_bucket.s3-bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  sns_topic_name                = aws_sns_topic.sns-topic.name


  # DS; enables all management events.
  advanced_event_selector {
    name = "Management Event Selector"
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  advanced_event_selector {
    name = "Custom Data Event Selector"

    # DS; enables data events (they pertain to s3 objects, lambda invocations, and dynamo db items). 
    # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html#logging-data-events
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    # DS; filters only events pertaining to s3 objects. Data events also include events about lambda invocations and dynamo db data items, this filters them out.
    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    # filters out events for objects in the s3 bucket which is used by this trail to store its logs otherwise it creates a cyclical series of events. 
    field_selector {
      field           = "resources.ARN"
      not_starts_with = ["${aws_s3_bucket.s3-bucket.arn}/"]
    }
  }

  depends_on = [
    aws_sns_topic.sns-topic,
    aws_s3_bucket_public_access_block.aws-bucket-access-block,
    aws_s3_bucket_policy.aws-bucket-policy
  ]
}

