provider "aws" {
  region = "us-east-2"
}

module "database" {
  source = "../../../../modules/data-stores/mysql"
  db_name = "mysql-prod"
  db_remote_state_bucket = "prod-mysql-bucket"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}