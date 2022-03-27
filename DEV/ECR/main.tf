provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "mn.xxwmm.marketing.terraformstate.remrqszkdw"
    key    = "basketanalyser/ecr/ecr-statefile"
    region = "eu-west-1"
  }
}

resource "aws_ecr_repository" "ecr_repo" {
    name	= "${var.owner_name}/${var.application_service}"
}

output "ecr_repository_name" {
  value = aws_ecr_repository.ecr_repo.name
}