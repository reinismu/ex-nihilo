output "private_key_pem" {
  value     = "${tls_private_key.private_key.private_key_pem}"
  sensitive = true
}

output "certificate" {
  value     = "${tls_locally_signed_cert.signed_certificate.cert_pem}"
  sensitive = true
}
