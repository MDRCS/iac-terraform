#output "public_ip" {
#  description = "The Public IP Address of the web server."
#  value = aws_instance.web_server_instance.public_ip
#  sensitive = false
#}

output "alb_dns_name" {
  value = aws_alb.example.dns_name
  description = "The domain name of the load balancer"

}

output "ip_address" {
  value = data.terraform_remote_state.db.outputs.address
  description = "Database's ip address"
}

output "db_port" {
  value = data.terraform_remote_state.db.outputs.port
  description = "Database's active port"
}