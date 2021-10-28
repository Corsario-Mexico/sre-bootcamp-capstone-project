terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "remote-states-workshop4-02"
    key            = "students/david-sol-capstone"
    encrypt        = true
    dynamodb_table = "David-Sol-terraform-lock"
  }
}
