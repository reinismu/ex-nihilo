# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-kubelet-client-certificates

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "certificate" {
  key_algorithm   = "${tls_private_key.private_key.algorithm}"
  private_key_pem = "${tls_private_key.private_key.private_key_pem}"

  ip_addresses = ["${var.ip_addresses}"]

  subject {
    common_name         = "${var.certificate_common_name}"
    organization        = "${var.certificate_organization}"
    country             = "US"
    locality            = "Portland"
    organizational_unit = "CA"
    province            = "Oregon"
  }
}

resource "tls_locally_signed_cert" "signed_certificate" {
  cert_request_pem   = "${tls_cert_request.certificate.cert_request_pem}"
  ca_key_algorithm   = "${var.certificate_authority_key_algorithm}"
  ca_private_key_pem = "${var.certificate_authority_private_key_pem}"
  ca_cert_pem        = "${var.certificate_authority_certificate}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "local_file" "key" {
  content  = "${tls_private_key.private_key.private_key_pem}"
  filename = "./.generated/tls/${var.certificate_name}-key.pem"
}

resource "local_file" "cert" {
  content  = "${tls_locally_signed_cert.signed_certificate.cert_pem}"
  filename = "./.generated/tls/${var.certificate_name}.pem"
}
