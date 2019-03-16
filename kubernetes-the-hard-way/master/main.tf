module "etcd" {
  source = "etcd"

  ssh_private_key                   = "${var.ssh_private_key}"
  ssh_user                          = "${var.ssh_user}"
  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  server_hostnames                  = "${var.server_hostnames}"
  server_private_ips                = "${var.server_private_ips}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  api_server_certificate            = "${var.api_server_certificate}"
  api_server_private_key_pem        = "${var.api_server_private_key_pem}"
}

module "apiserver" {
  source = "apiserver"

  etcd_id = "${module.etcd.etcd_done}"

  ssh_private_key                   = "${var.ssh_private_key}"
  ssh_user                          = "${var.ssh_user}"
  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  server_hostnames                  = "${var.server_hostnames}"
  server_private_ips                = "${var.server_private_ips}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  api_server_certificate            = "${var.api_server_certificate}"
  api_server_private_key_pem        = "${var.api_server_private_key_pem}"
  service_account_certificate       = "${var.service_account_certificate}"
  encryption_config                 = "${var.encryption_config}"
}

module "controller_manager" {
  source = "controller-manager"

  etcd_id = "${module.etcd.etcd_done}"

  ssh_private_key                       = "${var.ssh_private_key}"
  ssh_user                              = "${var.ssh_user}"
  load_balancer_public_ip               = "${var.load_balancer_public_ip}"
  server_hostnames                      = "${var.server_hostnames}"
  server_private_ips                    = "${var.server_private_ips}"
  certificate_authority_certificate     = "${var.certificate_authority_certificate}"
  certificate_authority_private_key_pem = "${var.certificate_authority_private_key_pem}"
  service_account_private_key_pem       = "${var.service_account_private_key_pem}"
  controller_manager_config             = "${var.controller_manager_config}"
}

module "scheduler" {
  source = "scheduler"

  etcd_id = "${module.etcd.etcd_done}"

  ssh_private_key         = "${var.ssh_private_key}"
  ssh_user                = "${var.ssh_user}"
  load_balancer_public_ip = "${var.load_balancer_public_ip}"
  server_hostnames        = "${var.server_hostnames}"
  server_private_ips      = "${var.server_private_ips}"
  scheduler_client_config = "${var.scheduler_client_config}"
}
