locals {
  event_rule_name = "${var.resource_prefix}-${terraform.workspace}-event-rule"
}

resource "aws_cloudwatch_event_rule" "kscope_crawler_rule" {
  name        = local.event_rule_name
  description = "Filters events from cloudtrail to an SQS Queue"
  event_pattern = jsonencode({
    "detail-type" : ["AWS API Call via CloudTrail"]
  })
}

resource "aws_cloudwatch_event_target" "kscope_event_target" {
  arn  = var.event_sqs_ingress_queue_arn
  rule = local.event_rule_name
  input_transformer {
    input_paths = {
      evt = {
        "evt": "$"
      }
    }
    input_template = {
      "CrawlConfigID": var.crawl_config_id,
      "Version": var.event_version,
      "Payload": <evt>
    }
  }
}
