variable "worker_server_hostnames" {
  type        = "list"
  description = "List of all worker server hostnames (should match with ips indecies)"
}

variable "master_server_private_ips" {
  type        = "list"
  description = "List of all master private ips"
}

variable "load_balancer_public_ip" {
  description = "List of all master ips"
}

variable "load_balancer_private_ip" {}
