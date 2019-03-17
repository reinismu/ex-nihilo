variable "ssh_user" {
  default     = "root"
  description = "User used for SSHing in server `ssh root@00.00.00.00`"
}

variable "load_balancer_public_ip" {
  description = "IP used to bastian in other hosts"
}

variable "server_private_ips" {
  type        = "list"
  description = "List of server private ips"
}

variable "worker_certificates" {
  type        = "list"
  description = "List of worker certificates"
}

variable "worker_private_keys" {
  type        = "list"
  description = "List of worker private keys"
}

variable "worker_configs" {
  type        = "list"
  description = "List of worker private keys"
}

variable "certificate_authority_certificate" {}

variable "kube_proxy_config" {}

variable "pod_cidr_mask" {
  default = "192.168.%s.0/16"
}
