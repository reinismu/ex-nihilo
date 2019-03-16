variable "kubernetes_version" {
  default = "v1.12.0"
}

variable "ssh_private_key" {
  type        = "string"
  description = "The path to your private key (ex. /.ssh/id_rsa)"
}

variable "ssh_user" {
  default     = "root"
  description = "User used for SSHing in server `ssh root@00.00.00.00`"
}

variable "server_ips" {
  type        = "list"
  description = "List of server ip addresses"
}

variable "server_hostnames" {
  type        = "list"
  description = "List of server hostnames"
}

variable "scheduler_client_config" {}