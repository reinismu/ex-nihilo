# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-kubelet-client-certificates

resource "tls_private_key" "worker_private_key" {
  count = "${length(var.worker_server_hostnames)}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "worker_certificate" {
  count = "${length(var.worker_server_hostnames)}"

  key_algorithm   = "${tls_private_key.worker_private_key.*.algorithm[count.index]}"
  private_key_pem = "${tls_private_key.worker_private_key.*.private_key_pem[count.index]}"

  subject {
    common_name         = "system:node:${element(var.worker_server_hostnames, count.index)}"
    organization        = "system:nodes"
    country             = "US"
    locality            = "Portland"
    organizational_unit = "CA"
    province            = "Oregon"
  }
}

resource "tls_locally_signed_cert" "worker_signed_certificate" {
  count              = "${length(var.worker_server_hostnames)}"
  cert_request_pem   = "${tls_cert_request.worker_certificate.*.cert_request_pem[count.index]}"
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

resource "local_file" "worker_key" {
  count = "${length(var.worker_server_hostnames)}"

  content  = "${tls_private_key.worker_private_key.*.private_key_pem[count.index]}"
  filename = "./.generated/tls/${element(var.worker_server_hostnames, count.index)}-key.pem"
}

resource "local_file" "worker_cert" {
  count = "${length(var.worker_server_hostnames)}"

  content  = "${tls_locally_signed_cert.worker_signed_certificate.*.cert_pem[count.index]}"
  filename = "./.generated/tls/${element(var.worker_server_hostnames, count.index)}.pem"
}
