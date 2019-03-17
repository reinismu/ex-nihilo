module "admin_certificate" {
  source = "certificate"

  certificate_name                      = "admin"
  certificate_common_name               = "admin"
  certificate_organization              = "system:masters"
  certificate_authority_key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  certificate_authority_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  certificate_authority_certificate     = "${tls_self_signed_cert.ca_certificate.cert_pem}"
}

module "controller_manager_certificate" {
  source = "certificate"

  certificate_name                      = "controller-manager"
  certificate_common_name               = "system:kube-controller-manager"
  certificate_organization              = "system:kube-controller-manager"
  certificate_authority_key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  certificate_authority_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  certificate_authority_certificate     = "${tls_self_signed_cert.ca_certificate.cert_pem}"
}

module "proxy_client_certificate" {
  source = "certificate"

  certificate_name                      = "proxy-client"
  certificate_common_name               = "system:kube-proxy"
  certificate_organization              = "system:node-proxier"
  certificate_authority_key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  certificate_authority_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  certificate_authority_certificate     = "${tls_self_signed_cert.ca_certificate.cert_pem}"
}

module "scheduler_client_certificate" {
  source = "certificate"

  certificate_name                      = "scheduler-client"
  certificate_common_name               = "system:kube-scheduler"
  certificate_organization              = "system:kube-scheduler"
  certificate_authority_key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  certificate_authority_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  certificate_authority_certificate     = "${tls_self_signed_cert.ca_certificate.cert_pem}"
}

module "api_server_certificate" {
  source = "certificate"

  ip_addresses = [
    "${var.master_server_private_ips}",
    "${var.load_balancer_public_ip}",
    "${var.load_balancer_private_ip}",
    "127.0.0.1",
    "10.32.0.1",
    "10.240.0.10",
    "10.240.0.11",
    "10.240.0.12",
  ]

  certificate_name                      = "api-server"
  certificate_common_name               = "kubernetes"
  certificate_organization              = "Kubernetes"
  certificate_authority_key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  certificate_authority_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  certificate_authority_certificate     = "${tls_self_signed_cert.ca_certificate.cert_pem}"
}

module "service_account_certificate" {
  source = "certificate"

  certificate_name                      = "service-account"
  certificate_common_name               = "service-accounts"
  certificate_organization              = "Kubernetes"
  certificate_authority_key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  certificate_authority_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  certificate_authority_certificate     = "${tls_self_signed_cert.ca_certificate.cert_pem}"
}
