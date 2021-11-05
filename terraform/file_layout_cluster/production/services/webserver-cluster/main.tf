provider "aws" {
  region = "us-east-2"
}

module "webserver-cluster" {
  # source = "github.com/brikis98/terraform-up-and-running-code//code/terraform/04-terraform-module/module-example/modules/services/webserver-cluster?ref=v0.1.0"
  source = "../../../../modules/services/webserver-cluster"
  cluster_name = "webserver-prod"
  instance_type = "m4.large" # prod != staging (you can use t2.micro)
  max_size = 10
  min_size = 2
  db_remote_state_bucket = "prod-cluster-s3-bucket"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
}

resource "aws_security_group" "allow_testing_inbound" {
  type = ingress
  security_group_id = module.webserver-cluster.alb_security_group_id
  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name  = "scale-out-during-business-hours"
  autoscaling_group_name = module.webserver-cluster.asg_name
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *" # cron job code means 9 am everyday
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name  = "scale-oin-at-night"
  autoscaling_group_name = module.webserver-cluster.asg_name
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *" # cron job code means 5 pm everyday
}

