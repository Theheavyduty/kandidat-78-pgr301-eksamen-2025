output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.main.dashboard_name
  description = "Navnet på CloudWatch dashboardet"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "SNS topic ARN for alarmer"
}

output "latency_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.avg_latency_high.alarm_name
  description = "Alarmnavn for høy gjennomsnittlig latens"
}
