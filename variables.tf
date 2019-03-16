variable "scw_org" {}

variable "scw_token" {}

# SSH key used here https://cloud.scaleway.com/#/credentials
variable "ssh_private_key" {
  type        = "string"
  description = "The path to your private key (ex. /.ssh/id_rsa)"
}

variable "region" {
  default = "ams1"
}

variable "master_type" {
  default     = "START1-S"
  description = "ScaleWay server type ex. C2S"
}

variable "master_count" {}

variable "worker_type" {
  default     = "START1-S"
  description = "ScaleWay server type ex. C2S"
}

variable "worker_count" {}

variable "prefix" {
  description = "Prefix that will be added to server names and resources"
}
