variable "load_balancer_public_ip" {
  description = "IP address of your load balancer (ex. Nginx pointing to all masters)"
}

variable "certificate_authority_certificate" {}

variable "worker_server_hostnames" {
  type        = "list"
  description = "List of all worker server hostnames (should match with ips indecies)"
}

variable "worker_server_certificates" {
  type = "list"
}

variable "worker_server_private_keys" {
  type = "list"
}

# proxy-client
variable "proxy_client_certificate" {}

variable "proxy_client_private_key" {}

# controller-manager
variable "controller_manager_certificate" {}

variable "controller_manager_private_key" {}

# scheduler-client
variable "scheduler_client_certificate" {}

variable "scheduler_client_private_key" {}

# admin
variable "admin_certificate" {}

variable "admin_private_key" {}
