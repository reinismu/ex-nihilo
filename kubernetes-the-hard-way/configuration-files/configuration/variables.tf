variable "load_balancer_public_ip" {
  description = "IP address of your load balancer (ex. Nginx pointing to all masters)"
}

variable "certificate_authority_certificate" {}

variable "config_name" {}

variable "context_user" {}

variable "users_name" {}

variable "client_certificate" {}

variable "client_private_key" {}
