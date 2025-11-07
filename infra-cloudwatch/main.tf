# SNS Topic + e-post subscription
resource "aws_sns_topic" "alerts" {
  name = "sentiment-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Dashboard (2+ widgets, tilpasset metrikktype)
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      # 1) Bedrock latency (ms) - timeSeries
      {
        "type" : "metric",
        "x" : 0, "y" : 0, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Bedrock latency (ms)",
          "view"  : "timeSeries",
          "region": var.region,
          "metrics" : [
            [ var.namespace, "sentiment.bedrock.duration.avg", { "stat": "Average" } ],
            [ ".",           "sentiment.bedrock.duration.max", { "stat": "Maximum" } ]
          ],
          "yAxis": { "left": { "label": "ms" } }
        }
      },

      # 2) Analyses per minute - timeSeries (Counter som Sum per periode)
      {
        "type" : "metric",
        "x" : 12, "y" : 0, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Analyses per minute",
          "view"  : "timeSeries",
          "region": var.region,
          "metrics" : [
            [ var.namespace, "sentiment.analysis.count.count", { "stat": "Sum" } ]
          ]
        }
      },

      # 3) Companies detected (siste) - singleValue (Gauge)
      {
        "type" : "metric",
        "x" : 0, "y" : 6, "width" : 6, "height" : 4,
        "properties" : {
          "title" : "Companies detected (last)",
          "view"  : "singleValue",
          "region": var.region,
          "metrics" : [
            [ var.namespace, "sentiment.companies.last.value", { "stat": "Average" } ]
          ]
        }
      },

      # 4) Confidence avg - singleValue
      {
        "type" : "metric",
        "x" : 6, "y" : 6, "width" : 6, "height" : 4,
        "properties" : {
          "title" : "Confidence (avg)",
          "view"  : "singleValue",
          "region": var.region,
          "metrics" : [
            [ var.namespace, "sentiment.confidence.avg", { "stat": "Average" } ]
          ]
        }
      }
    ]
  })
}

# Alarm A: Høy latens (metric math: sum/count > threshold)
resource "aws_cloudwatch_metric_alarm" "latency_high" {
  alarm_name          = "sentiment-bedrock-latency-high"
  alarm_description   = "Average Bedrock latency > ${var.latency_threshold_ms} ms"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.latency_threshold_ms
  evaluation_periods  = var.latency_evaluation_periods
  datapoints_to_alarm = var.latency_datapoints_to_alarm
  treat_missing_data  = "notBreaching"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  # Metric math: avg latency = sum / count
  metric_query {
    id = "m_sum"
    metric {
      namespace   = var.namespace
      metric_name = "sentiment.bedrock.duration.sum"
      stat        = "Sum"
      period      = var.metric_period_seconds
    }
  }

  metric_query {
    id = "m_count"
    metric {
      namespace   = var.namespace
      metric_name = "sentiment.bedrock.duration.count"
      stat        = "Sum"
      period      = var.metric_period_seconds
    }
  }

  metric_query {
    id          = "e1"
    expression  = "m_sum / m_count"
    label       = "avg latency (ms)"
    return_data = true
  }



}


# Alarm B: Ingen analyser (lett å trigge for test/demo)
resource "aws_cloudwatch_metric_alarm" "no_traffic" {
  alarm_name          = "sentiment-no-analyses"
  alarm_description   = "No analyses observed in the last ${var.metric_period_seconds}s"
  namespace           = var.namespace
  metric_name         = "sentiment.analysis.count.count"
  statistic           = "Sum"
  period              = var.metric_period_seconds
  evaluation_periods  = var.no_traffic_evaluation_periods
  datapoints_to_alarm = 1
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = 0
  # gjør test enklere: hvis ingen datapunkter => ALARM
  treat_missing_data  = "breaching"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}
