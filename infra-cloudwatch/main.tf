terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "pgr301-terraform-state"
    key    = "infra-cloudwatch/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.region
}

# ---------------- SNS ----------------
resource "aws_sns_topic" "alerts" {
  name = "${var.prefix}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ------------- Dashboard -------------
locals {
  dashboard_body = templatefile("${path.module}/dashboard.json.tmpl", {
    region   = var.region
    namespace = var.namespace
    company  = var.company
    model    = var.model
    period   = var.dashboard_period
    title    = var.prefix
  })
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name
  dashboard_body = local.dashboard_body
}

# --------------- Alarm ---------------
# Alarm på gjennomsnittlig Bedrock-latens (ms) via metric math: m1/m2
resource "aws_cloudwatch_metric_alarm" "avg_latency_high" {
  alarm_name          = "${var.prefix}-avg-latency-high"
  alarm_description   = "Average latency > ${var.latency_threshold_ms} ms for ${var.company} ${var.model}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  threshold           = var.latency_threshold_ms
  treat_missing_data  = "notBreaching"

  # m1 = sum(ms)
  metric_query {
    id          = "m1"
    return_data = false

    metric {
      namespace   = var.namespace
      metric_name = "sentiment.bedrock.duration.sum"
      stat        = "Sum"
      unit        = "Milliseconds"
      period      = var.alarm_period

      dimensions = {
        company = var.company
        model   = var.model
      }
    }
  }

  # m2 = count
  metric_query {
    id          = "m2"
    return_data = false

    metric {
      namespace   = var.namespace
      metric_name = "sentiment.bedrock.duration.count"
      stat        = "Sum"
      unit        = "Count"
      period      = var.alarm_period

      dimensions = {
        company = var.company
        model   = var.model
      }
    }
  }

  # e1 = avg latency ms
  metric_query {
    id          = "e1"
    label       = "avgLatencyMs"
    return_data = true
    expression  = "IF(m2>0,m1/m2,0)"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
  depends_on    = [aws_sns_topic_subscription.email]
}
