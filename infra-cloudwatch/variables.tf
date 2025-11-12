variable "region" {
  description = "AWS region for CloudWatch/SNS"
  type        = string
  default     = "eu-west-1"
}

variable "namespace" {
  description = "CloudWatch namespace som appen publiserer til (må matche MetricsConfig)"
  type        = string
}

variable "dashboard_name" {
  description = "Navn på CloudWatch Dashboard"
  type        = string
  default     = "sentiment-observability"
}

variable "alarm_email" {
  description = "E-post for SNS-varsel (må bekreftes)"
  type        = string
}

variable "metric_period_seconds" {
  description = "Periode (sek) for metrics/alarmer"
  type        = number
  default     = 60
}

# Høy-latens alarm (gjennomsnitt > terskel i ms)
variable "latency_threshold_ms" {
  description = "Alarmterskel for gjennomsnittlig Bedrock-latens (ms)"
  type        = number
  default     = 5000
}

variable "latency_evaluation_periods" {
  description = "Antall evalueringsperioder for latensalarmen"
  type        = number
  default     = 3
}

variable "latency_datapoints_to_alarm" {
  description = "Datapunkter som må bryte terskel for å alarmere"
  type        = number
  default     = 2
}

# “No traffic”-alarm: enkelt å trigge manuelt
variable "no_traffic_evaluation_periods" {
  description = "Perioder uten trafikk før alarm"
  type        = number
  default     = 1
}