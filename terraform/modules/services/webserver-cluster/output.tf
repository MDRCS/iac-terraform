#output "public_ip" {
#  description = "The Public IP Address of the web server."
#  value = aws_instance.web_server_instance.public_ip
#  sensitive = false
#}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer"

}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
  description = "The ID of the Security Group attached to the load balancer"
}

output "ip_address" {
  value = data.terraform_remote_state.db.outputs.address
  description = "Database's ip address"
}

output "db_port" {
  value = data.terraform_remote_state.db.outputs.port
  description = "Database's active port"
}

output "asg_name" {
  value = aws_autoscaling_group.example.name
  description = "Auto scaling group's name"
}