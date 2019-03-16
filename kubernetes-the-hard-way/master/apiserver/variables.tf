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

variable "load_balancer_public_ip" {
  description = "IP used to bastion in other hosts"
}

variable "server_hostnames" {
  type        = "list"
  description = "List of server hostnames"
}

variable "server_private_ips" {
  type        = "list"
  description = "List of server private ips"
}

variable "certificate_authority_certificate" {}

variable "api_server_certificate" {}

variable "api_server_private_key_pem" {}

variable "service_account_certificate" {}

variable "encryption_config" {}

# Used to make sure that this is run after etcd has been setup
variable "etcd_id" {}
