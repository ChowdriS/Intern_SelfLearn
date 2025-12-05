provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "demo" {
  bucket = "chowdri-demo-bucket-123456"
}

# jenkins - 04cc65fc6b9c4b3f905ccb8379c8b2b0