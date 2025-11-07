terraform {
required_version = ">= 1.6.6"


required_providers {
aws = {
source = "hashicorp/aws"
version = ">= 5.0"
}
}


# Terraform state i S3 (krav)

#test
backend "s3" {
bucket = "pgr301-terraform-state"
key = "kandidat-<KANDIDATNR>/infra-s3/terraform.tfstate" # Overstyres i CI
region = "eu-west-1"
encrypt = true
# dynamodb_table = "pgr301-terraform-lock" # valgfritt hvis tabellen finnes
}
}


provider "aws" {
region = var.aws_region
}