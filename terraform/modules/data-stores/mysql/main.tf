provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-example"
  engine = "mysql"
  allocated_storage = 10 # 10 GB
  instance_class = "db.t2.micro" # 1 CPU instance
  name = var.db_name
  username = "admin"
#  skip_final_snapshot= true # Force destroy

  # How we should set password
  password = var.db_password


# password = data.aws_secretsmanager_secret_version.db_password.secret_string

}

#data "aws_secretsmanager_secret_version" "db_password" {
#  secret_id = "mysql-master-password-stage"
#}

terraform {
  backend "s3" {

    bucket         = var.db_remote_state_bucket
    key            = var.db_remote_state_key
    region         = "us-east-2"
    dynamodb_table = "terraform-locks-example-test"
    encrypt = true
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket         = var.db_remote_state_bucket
    key            = var.db_remote_state_key
    region = "us-east-2"
  }

}