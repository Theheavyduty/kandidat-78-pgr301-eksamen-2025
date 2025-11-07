terraform {
  required_version = ">= 1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Statelagres i pgr301-terraform-state (samme som tidligere oppgaver).
  # Du kan angi region ved init: -backend-config="region=eu-west-1"
  backend "s3" {
    bucket = "pgr301-terraform-state"
    key    = "infra-cloudwatch/terraform.tfstate"
    # region settes ved init eller arves fra env (AWS_REGION)
  }
}

provider "aws" {
  region = var.region
}
