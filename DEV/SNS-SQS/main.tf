provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "mn.xxwmm.marketing.terraformstate.remrqszkdw"
    key = "coupon/env/dev/sqs/eecampaigns/sqs-statefile"
    region = "eu-west-1"
  }
}

## ee campaign handling queue and dead letter queue
resource "aws_sqs_queue" "coupon_ee_campaign_strd_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_ee_campaign}-strd-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.coupon_ee_campaign_dead_queue.arn
    maxReceiveCount = 5
  })
}

output "ee_campaign_strd_queue" {
  value = aws_sqs_queue.coupon_ee_campaign_strd_queue.name
}

resource "aws_sqs_queue" "coupon_ee_campaign_dead_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_ee_campaign}-dead-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
}

output "ee_campaign_dead_queue" {
  value = aws_sqs_queue.coupon_ee_campaign_dead_queue.name
}

## ee coupon handling queue and dead letter queue
resource "aws_sqs_queue" "coupon_ee_coupon_strd_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_ee_coupon}-strd-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.coupon_ee_coupon_dead_queue.arn
    maxReceiveCount = 5
  })
}

output "ee_coupon_strd_queue" {
  value = aws_sqs_queue.coupon_ee_coupon_strd_queue.name
}

resource "aws_sqs_queue" "coupon_ee_coupon_dead_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_ee_coupon}-dead-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
}

output "ee_coupon_dead_queue" {
  value = aws_sqs_queue.coupon_ee_coupon_dead_queue.name
}

## valassis error handling queue and dead letter queue
resource "aws_sqs_queue" "coupon_valassis_error_strd_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_valassis_error}-strd-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.coupon_valassis_error_dead_queue.arn
    maxReceiveCount = 5
  })
}

output "valassis_error_strd_queue" {
  value = aws_sqs_queue.coupon_valassis_error_strd_queue.name
}

resource "aws_sqs_queue" "coupon_valassis_error_dead_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_valassis_error}-dead-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
}

output "valassis_error_dead_queue" {
  value = aws_sqs_queue.coupon_valassis_error_dead_queue.name
}

## redeem process handling queue and dead letter queue
resource "aws_sqs_queue" "coupon_redeem_strd_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_redeem}-strd-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.coupon_redeem_dead_queue.arn
    maxReceiveCount = 5
  })
}

output "redeem_strd_queue" {
  value = aws_sqs_queue.coupon_redeem_strd_queue.name
}

resource "aws_sqs_queue" "coupon_redeem_dead_queue" {
  name = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.q_name_redeem}-dead-${var.seq_id}"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue = var.fifo_queue
  tags = var.default_tags
}

output "redeem_dead_queue" {
  value = aws_sqs_queue.coupon_redeem_dead_queue.name
}

## sns topic to handle valassis errors for notifications to Support and publish to error queues
resource "aws_sns_topic" "coupon_valassis_error_sns_topic" {
  name = "sns-${var.region_code}-${var.environment}-${var.owner_name}-${var.app_service_short}-${var.topic_name_valassis_error}-${var.seq_id}"
  tags = var.default_tags
}

# Subscribe our queue to the topic
resource "aws_sns_topic_subscription" "sns_to_sqs_valassis_error" {
  topic_arn = aws_sns_topic.coupon_valassis_error_sns_topic.arn
  protocol = "sqs"
  endpoint = aws_sqs_queue.coupon_valassis_error_strd_queue.arn
  raw_message_delivery = true
  filter_policy = jsonencode({
    "ErrorCodes": [
      "0000-InternalCouponServiceFailure",
      "0001-ValassisNetworkFailure",
      "0002-ValassisSystemFailure",
      "0003-ValassisApplicationFailure",
      "0004-ValassisTimeOutFailure"
    ]
  })
}

output "valassis_error_sns_topic" {
  value = aws_sns_topic.coupon_valassis_error_sns_topic.name
}

## iam policy changes to allow sns to send messages to queue
resource "aws_sqs_queue_policy" "coupon_valassis_error_strd_queue_policy" {
  queue_url = aws_sqs_queue.coupon_valassis_error_strd_queue.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.coupon_valassis_error_strd_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.coupon_valassis_error_sns_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}