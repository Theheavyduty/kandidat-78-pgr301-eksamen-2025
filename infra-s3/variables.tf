variable "bucket_name" {
description = "Navn på S3-bucket for analyseresultater. Må være globalt unikt."
type = string
}


variable "aws_region" {
description = "AWS region for ressursene."
type = string
default = "eu-west-1"
}


variable "temp_prefix" {
description = "Prefix (mappe) for midlertidige filer som skal auto-håndteres."
type = string
default = "midlertidig/"
}


variable "transition_days" {
description = "Dager før midlertidige objekter flyttes til billigere lagringsklasse."
type = number
default = 7
}


variable "expiration_days" {
description = "Dager før midlertidige objekter slettes permanent."
type = number
default = 30
}


variable "tags" {
description = "Felles tags for ressursene."
type = map(string)
default = {
Project = "AiAlpha"
ManagedBy = "Terraform"
}
}