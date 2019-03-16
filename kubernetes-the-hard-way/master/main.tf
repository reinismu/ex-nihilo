module "etcd" {
  source = "etcd"

  ssh_private_key                   = "${var.ssh_private_key}"
  ssh_user                          = "${var.ssh_user}"
  server_ips                        = "${var.server_ips}"
  server_hostnames                  = "${var.server_hostnames}"
  server_private_ips                = "${var.server_private_ips}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  api_server_certificate            = "${var.api_server_certificate}"
  api_server_private_key_pem        = "${var.api_server_private_key_pem}"
}

module "apiserver" {
  source = "apiserver"

  ssh_private_key                   = "${var.ssh_private_key}"
  ssh_user                          = "${var.ssh_user}"
  server_ips                        = "${var.server_ips}"
  server_hostnames                  = "${var.server_hostnames}"
  server_private_ips                = "${var.server_private_ips}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  api_server_certificate            = "${var.api_server_certificate}"
  api_server_private_key_pem        = "${var.api_server_private_key_pem}"
  service_account_certificate       = "${var.service_account_certificate}"
  encryption_config                 = "${var.encryption_config}"
}
