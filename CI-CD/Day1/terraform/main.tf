provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "demo" {
  bucket = "chowdri-demo-bucket-123456"
}

# jenkins pass - bebea54ead444f9b94b57db8d8b236a4