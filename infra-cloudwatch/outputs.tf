output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.this.dashboard_name
  description = "CloudWatch dashboard name"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "SNS topic ARN for alerts"
}

output "alarm_latency_name" {
  value       = aws_cloudwatch_metric_alarm.latency_high.alarm_name
  description = "High latency alarm name"
}

output "alarm_no_traffic_name" {
  value       = aws_cloudwatch_metric_alarm.no_traffic.alarm_name
  description = "No traffic alarm name"
}