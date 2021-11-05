provider "aws" {
  region = "us-east-2"
}

module "webserver-cluster" {
  source = "../../../../modules/services/webserver-cluster"
  cluster_name = "webserver-prod"
  instance_type = "m4.large" # prod != staging (you can use t2.micro)
  max_size = 10
  min_size = 2
  db_remote_state_bucket = "prod-cluster-s3-bucket"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
}