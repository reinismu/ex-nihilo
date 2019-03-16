variable "ssh_private_key" {
  type        = "string"
  description = "The path to your private key (ex. /.ssh/id_rsa)"
}

variable "ssh_user" {
  default     = "root"
  description = "User used for SSHing in server `ssh root@00.00.00.00`"
}

variable "load_balancer_public_ip" {
  description = "IP address of your load balancer (ex. Nginx pointing to all masters)"
}

variable "master_server_ips" {
  type        = "list"
  description = "List of all master server ips"
}

variable "master_server_hostnames" {
  type        = "list"
  description = "List of all master server hostnames"
}

variable "master_server_private_ips" {
  type        = "list"
  description = "List of all master server private ips"
}

variable "worker_server_ips" {
  type        = "list"
  description = "List of all worker server ips"
}

variable "worker_server_hostnames" {
  type        = "list"
  description = "List of all worker server hostnames"
}

variable "worker_server_private_ips" {
  type        = "list"
  description = "List of all worker server private ips"
}
