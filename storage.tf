resource "aws_s3_bucket" "energy_bucket" {
  bucket = local.bucket_name
}