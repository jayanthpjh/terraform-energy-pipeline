provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "suffix" {
  length = 2
}

locals {
  bucket_name       = "energy-bucket-${random_pet.suffix.id}"
  dynamodb_name     = "energy_data_${random_pet.suffix.id}"
  lambda_exec_role  = "lambda-exec-${random_pet.suffix.id}"
  sns_topic_name    = "anomaly-alert-${random_pet.suffix.id}"
}