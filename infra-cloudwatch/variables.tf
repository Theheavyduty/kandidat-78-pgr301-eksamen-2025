variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region"
}

variable "namespace" {
  type        = string
  default     = "kandidat-78-SentimentApp" 
  description = "CloudWatch namespace for app-metrikker"
}

variable "prefix" {
  type        = string
  default     = "kandidat78"
  description = "Navneprefix for ressurser (dashboard, alarmer, SNS)"
}

variable "dashboard_name" {
  type        = string
  default     = "kandidat78"
  description = "CloudWatch dashboard name"
}

variable "company" {
  type        = string
  default     = "NVIDIA"
  description = "Standard dimensjon: company"
}

variable "model" {
  type        = string
  default     = "amazon.nova-micro-v1:0"
  description = "Standard dimensjon: model"
}

variable "dashboard_period" {
  type        = number
  default     = 300
  description = "Periode (sek) for dashboard-widgets"
}

variable "alarm_period" {
  type        = number
  default     = 300
  description = "Periode (sek) for alarm-evaluering"
}

variable "evaluation_periods" {
  type        = number
  default     = 3
  description = "Antall perioder som må bryte terskel"
}

variable "latency_threshold_ms" {
  type        = number
  default     = 1000
  description = "Terskel for gj.snitt-latens i ms (fornuftig baseline ~1s i din test)"
}

variable "alarm_email" {
  type        = string
  description = "E-postadresse for SNS subscription (må bekreftes)"
}
