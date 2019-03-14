# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-admin-client-certificate

resource "tls_private_key" "scheduler_client_private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "scheduler_client_certificate" {
  key_algorithm   = "${tls_private_key.scheduler_client_private_key.algorithm}"
  private_key_pem = "${tls_private_key.scheduler_client_private_key.private_key_pem}"

  subject {
    common_name         = "system:kube-scheduler"
    organization        = "system:kube-scheduler"
    country             = "US"
    locality            = "Portland"
    organizational_unit = "CA"
    province            = "Oregon"
  }
}

resource "tls_locally_signed_cert" "scheduler_client_signed_certificate" {
  cert_request_pem   = "${tls_cert_request.scheduler_client_certificate.cert_request_pem}"
  ca_key_algorithm   = "${tls_private_key.ca_private_key.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca_certificate.cert_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "local_file" "scheduler_client_key" {
  content  = "${tls_private_key.scheduler_client_private_key.private_key_pem}"
  filename = "./.generated/tls/scheduler-client-key.pem"
}

resource "local_file" "scheduler_client_cert" {
  content  = "${tls_locally_signed_cert.scheduler_client_signed_certificate.cert_pem}"
  filename = "./.generated/tls/scheduler-client.pem"
}
