variable "certificate_name" {
  description = "Certificate name (ex. scheduler-client)"
}

variable "certificate_authority_key_algorithm" {
  description = "ex. RSA"
}

variable "ip_addresses" {
  type    = "list"
  default = []
}

variable "certificate_common_name" {}

variable "certificate_organization" {}

variable "certificate_authority_private_key_pem" {}

variable "certificate_authority_certificate" {}
