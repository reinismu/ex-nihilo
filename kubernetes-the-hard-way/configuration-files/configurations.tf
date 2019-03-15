module "proxy-client" {
  source = "configuration"

  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  config_name                       = "proxy-client"
  context_user                      = "kube-proxy"
  users_name                        = "kube-proxy"
  client_certificate                = "${var.proxy_client_certificate}"
  client_private_key                = "${var.proxy_client_private_key}"
}

module "controller-manager" {
  source = "configuration"

  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  config_name                       = "controller-manager"
  context_user                      = "system:kube-controller-manager"
  users_name                        = "system:kube-controller-manager "
  client_certificate                = "${var.controller_manager_certificate}"
  client_private_key                = "${var.controller_manager_certificate}"
}

module "scheduler-client" {
  source = "configuration"

  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  config_name                       = "scheduler-client"
  context_user                      = "system:kube-scheduler"
  users_name                        = "system:kube-scheduler"
  client_certificate                = "${var.scheduler_client_certificate}"
  client_private_key                = "${var.scheduler_client_private_key}"
}

module "admin" {
  source = "configuration"

  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  config_name                       = "admin"
  context_user                      = "admin"
  users_name                        = "admin"
  client_certificate                = "${var.admin_certificate}"
  client_private_key                = "${var.admin_private_key}"
}
