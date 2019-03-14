variable "ssh_private_key" {
  type        = "string"
  description = "The path to your private key (ex. /.ssh/id_rsa)"
}

variable "ssh_user" {
  default     = "root"
  description = "User used for SSHing in server `ssh root@00.00.00.00`"
}

variable "master_server_ip" {
  description = "List of all master server ips"
}

variable "master_server_hostnames" {
 description = "List of all master server hostnames (should match with ips indecies)"
}

variable "worker_server_ips" {
  description = "List of all worker server ips"
}

variable "worker_server_hostnames" {
  description = "List of all worker server hostnames (should match with ips indecies)"
}
