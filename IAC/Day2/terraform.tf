terraform {
  backend "s3" {
    bucket         = "chow3-terraform-state"   
    key            = "terraform.tfstate"  
    region         = "us-east-1"
    dynamodb_table = "chow3-lock-dt"
    encrypt        = true
  }
}