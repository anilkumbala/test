provider "aws" {
  region = "eu-west-1"
}

resource "aws_sqs_queue" "custpromo_dead_queue" {
  name                      = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.q_type}-dead-${var.seq_id}"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue                = var.fifo_queue
  tags 					    = var.default_tags
}

output "dead_queue_name" {
  value = aws_sqs_queue.custpromo_dead_queue.name
}

resource "aws_sqs_queue" "custpromo_strd_queue" {
  name                      = "sqs-${var.region_code}-${var.environment}-${var.owner_name}-${var.q_type}-strd-${var.seq_id}"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  fifo_queue                = var.fifo_queue
  tags 					    = var.default_tags
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.custpromo_dead_queue.arn
    maxReceiveCount     = 5
  })
  }
  
  output "strd_queue_name" {
  value = aws_sqs_queue.custpromo_strd_queue.name
}
