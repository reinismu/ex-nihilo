variable "etcd_version" {
  default = "v3.3.9"
}

variable "ssh_private_key" {
  type        = "string"
  description = "The path to your private key (ex. /.ssh/id_rsa)"
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

variable "server_hostnames" {
  type        = "list"
  description = "List of server hostnames"
}

variable "certificate_authority_certificate" {}

variable "api_server_certificate" {}

variable "api_server_private_key_pem" {}
