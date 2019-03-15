# certificate-authority
output "certificate_authority_private_key_pem" {
  value     = "${tls_private_key.ca_private_key.private_key_pem}"
  sensitive = true
}

output "certificate_authority_certificate" {
  value     = "${tls_self_signed_cert.ca_certificate.cert_pem}"
  sensitive = true
}

# admin
output "admin_private_key_pem" {
  value     = "${module.admin_certificate.private_key_pem}"
  sensitive = true
}

output "admin_certificate" {
  value     = "${module.admin_certificate.certificate}"
  sensitive = true
}

# controller-manager
output "controller_manager_private_key_pem" {
  value     = "${module.controller_manager_certificate.private_key_pem}"
  sensitive = true
}

output "controller_manager_certificate" {
  value     = "${module.controller_manager_certificate.certificate}"
  sensitive = true
}

# ploxy-client
output "proxy_client_private_key_pem" {
  value     = "${module.proxy_client_certificate.private_key_pem}"
  sensitive = true
}

output "proxy_client_certificate" {
  value     = "${module.proxy_client_certificate.certificate}"
  sensitive = true
}

# scheduler-client
output "scheduler_client_private_key_pem" {
  value     = "${module.scheduler_client_certificate.private_key_pem}"
  sensitive = true
}

output "scheduler_client_certificate" {
  value     = "${module.scheduler_client_certificate.certificate}"
  sensitive = true
}

# api-server
output "api_server_private_key_pem" {
  value     = "${module.api_server_certificate.private_key_pem}"
  sensitive = true
}

output "api_server_certificate" {
  value     = "${module.api_server_certificate.certificate}"
  sensitive = true
}

# service-account
output "service_account_private_key_pem" {
  value     = "${module.service_account_certificate.private_key_pem}"
  sensitive = true
}

output "service_account_certificate" {
  value     = "${module.service_account_certificate.certificate}"
  sensitive = true
}

# workers
output "worker_private_key_pems" {
  value     = "${tls_private_key.worker_private_key.*.private_key_pem}"
  sensitive = true
}

output "worker_certificates" {
  value     = "${tls_locally_signed_cert.worker_signed_certificate.*.cert_pem}"
  sensitive = true
}
