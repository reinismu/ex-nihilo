# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#certificate-authority

resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "ca_certificate" {
  key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"

  subject {
    common_name         = "Kubernetes"
    organization        = "Kubernetes"
    country             = "US"
    locality            = "Portland"
    organizational_unit = "CA"
    province            = "Oregon"
  }

  is_ca_certificate     = true
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "local_file" "ca_key" {
  content  = "${tls_private_key.ca_private_key.private_key_pem}"
  filename = "./.generated/tls/certificate-authority-key.pem"
}

resource "local_file" "ca_cert" {
  content  = "${tls_self_signed_cert.ca_certificate.cert_pem}"
  filename = "./.generated/tls/certificate-authority.pem"
}
