# Create PKI
module "public_key_infrastructure" {
  source = "public-key-infrastructure"

  worker_server_hostnames   = "${var.worker_server_hostnames}"
  master_server_private_ips = "${var.master_server_private_ips}"
  load_balancer_public_ip   = "${var.load_balancer_public_ip}"
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

# Start master servers with proper services and configurations
module "master" {
  source = "master"

  ssh_private_key                       = "${var.ssh_private_key}"
  ssh_user                              = "${var.ssh_user}"
  load_balancer_public_ip               = "${var.load_balancer_public_ip}"
  server_hostnames                      = "${var.master_server_hostnames}"
  server_private_ips                    = "${var.master_server_private_ips}"
  certificate_authority_certificate     = "${module.public_key_infrastructure.certificate_authority_certificate}"
  certificate_authority_private_key_pem = "${module.public_key_infrastructure.certificate_authority_private_key_pem}"
  api_server_certificate                = "${module.public_key_infrastructure.api_server_certificate}"
  api_server_private_key_pem            = "${module.public_key_infrastructure.api_server_private_key_pem}"
  service_account_certificate           = "${module.public_key_infrastructure.service_account_certificate}"
  service_account_private_key_pem       = "${module.public_key_infrastructure.service_account_private_key_pem}"
  encryption_config                     = "${module.encryption_config.encryption_config}"
  controller_manager_config             = "${module.configuration_files.controller_manager_config}"
  scheduler_client_config               = "${module.configuration_files.scheduler_client_config}"
}
