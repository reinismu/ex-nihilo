# Create PKI
module "public_key_infrastructure" {
  source = "public-key-infrastructure"

  worker_server_hostnames = "${var.worker_server_hostnames}"
}

# Create configuration files
module "configuration_files" {
  source = "configuration-files"

  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  certificate_authority_certificate = "${module.public_key_infrastructure.certificate_authority_certificate}"

  worker_server_hostnames    = "${var.worker_server_hostnames}"
  worker_server_certificates = "${module.public_key_infrastructure.worker_certificates}"
  worker_server_private_keys = "${module.public_key_infrastructure.worker_private_key_pems}"

  proxy_client_certificate = "${module.public_key_infrastructure.proxy_client_certificate}"
  proxy_client_private_key = "${module.public_key_infrastructure.proxy_client_private_key_pem}"

  controller_manager_certificate = "${module.public_key_infrastructure.controller_manager_certificate}"
  controller_manager_private_key = "${module.public_key_infrastructure.controller_manager_private_key_pem}"

  scheduler_client_certificate = "${module.public_key_infrastructure.scheduler_client_certificate}"
  scheduler_client_private_key = "${module.public_key_infrastructure.scheduler_client_private_key_pem}"

  admin_certificate = "${module.public_key_infrastructure.admin_certificate}"
  admin_private_key = "${module.public_key_infrastructure.admin_private_key_pem}"
}

# Create encryption config
module "encryption_config" {
  source = "encryption-config"
}
