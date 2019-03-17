variable "runc_version" {
  default = "v1.0.0-rc5"
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

variable "pod_cidr" {
  default = "192.168.0.0/16"
}

variable "kube_proxy_config" {}
