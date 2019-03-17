variable "cni_version" {
  default = "v0.6.0"
}

variable "ssh_user" {
  default     = "root"
  description = "User used for SSHing in server `ssh root@00.00.00.00`"
}

variable "load_balancer_public_ip" {
  description = "IP used to bastion in other hosts"
}

variable "server_private_ips" {
  type        = "list"
  description = "List of server private ips"
}


variable "pod_cidr_mask" {
}
