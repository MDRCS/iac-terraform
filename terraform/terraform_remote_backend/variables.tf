variable "s3_bucket_name" {
  description = "S3 bucket's name for terraform state file"
  type = string
  default = "terraform-remote-state-example-test"
}

variable "dynamodb_table_name" {
  description = "Dynamodb table's name for locks."
  default = "terraform-locks-example-test"
  type = string
}