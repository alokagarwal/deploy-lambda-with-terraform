terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "devopsy-terraform"
    key    = "python-lambda-state"
    region = "us-east-1"
  }
}
