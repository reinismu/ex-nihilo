variable "ssh_user" {
  default     = "root"
  description = "User used for SSHing in server `ssh root@00.00.00.00`"
}

variable "server_count" {}

variable "my_ip" {
  description = "Limit all external to my ip"
}

variable "load_balancer_public_ip" {
  description = "IP used to bastion in other hosts"
}

variable "server_private_ips" {
  type        = "list"
  description = "List of server private ips"
}
