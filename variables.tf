variable "aws_region" {
    default = "ap-southeast-1"
}

variable "project_name" {
    default = "jru-pulse"
}

variable "app_count" {
  type    = number
  default = 1
}


variable "db_password" {
  description = "RDS Root Password"
  type        = string
  sensitive   = true
}

variable "google_client_id" {
  type      = string
  sensitive = true
}

variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "mail_password" {
  type      = string
  sensitive = true
}

