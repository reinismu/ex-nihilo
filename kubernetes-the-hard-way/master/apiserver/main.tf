locals {
  # If you change paths make sure that those directories exist or create them!
  ca_cert_dest                = "/var/lib/kubernetes/ca.pem"
  api_server_cert_dest        = "/var/lib/kubernetes/api-server.pem"
  api_server_private_key_dest = "/var/lib/kubernetes/api-server-key.pem"
  service_account_cert_dest   = "/var/lib/kubernetes/service-account.pem"
  encryption_config_dest      = "/var/lib/kubernetes/encryption-config.yaml"
}

# Download apiserver binary
resource "null_resource" "apiserver_binary" {
  count = "${length(var.server_ips)}"

  triggers = {
    version = "${var.kubernetes_version}"
  }

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
    host = "${element(var.server_ips, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "wget -q --show-progress --https-only --timestamping 'https://storage.googleapis.com/kubernetes-release/release/${var.kubernetes_version}/bin/linux/amd64/kube-apiserver'",
      "chmod +x kube-apiserver",
      "sudo mv kube-apiserver /usr/local/bin/",
    ]
  }
}

data "template_file" "apiserver_service_template" {
  count = "${length(var.server_ips)}"

  template = "${file("${path.module}/apiserver.service.tpl")}"

  vars {
    PRIVATE_IP                  = "${element(var.server_private_ips, count.index)}"
    API_SERVER_CERT_PATH        = "${local.api_server_cert_dest}"
    API_SERVER_PRIVATE_KEY_PATH = "${local.api_server_private_key_dest}"
    CA_CERT_PATH                = "${local.ca_cert_dest}"
    SERVICE_ACCOUNT_CERT_PATH   = "${local.service_account_cert_dest}"
    ENCRYPTION_CONFIG           = "${local.encryption_config_dest}"
    ETCD_SERVER_LIST            = "${join(",",formatlist("https://%s:2379", var.server_private_ips))}"
  }
}

resource "local_file" "apiserver_config" {
  count    = "${length(var.server_ips)}"
  content  = "${data.template_file.apiserver_service_template.*.rendered[count.index]}"
  filename = "./.generated/${element(var.server_hostnames, count.index)}.apiserver.service"
}

# Configure the apiserver server
resource "null_resource" "apiserver_server" {
  count = "${length(var.server_ips)}"

  triggers = {
    rendered_content = "${data.template_file.apiserver_service_template.*.rendered[count.index]}"
    binary           = "${null_resource.apiserver_binary.*.id[count.index]}"
  }

  depends_on = ["local_file.apiserver_config"]

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
    host = "${element(var.server_ips, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/lib/kubernetes/",
    ]
  }

  provisioner "file" {
    content     = "${var.encryption_config}"
    destination = "${local.encryption_config_dest}"
  }

  provisioner "file" {
    content     = "${var.certificate_authority_certificate}"
    destination = "${local.ca_cert_dest}"
  }

  provisioner "file" {
    content     = "${var.api_server_certificate}"
    destination = "${local.api_server_cert_dest}"
  }

  provisioner "file" {
    content     = "${var.api_server_private_key_pem}"
    destination = "${local.api_server_private_key_dest}"
  }

  provisioner "file" {
    content     = "${var.service_account_certificate}"
    destination = "${local.service_account_cert_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.apiserver_service_template.*.rendered[count.index]}"
    destination = "/etc/systemd/system/kube-apiserver.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable kube-apiserver",
      "sudo systemctl start kube-apiserver",
      "sleep 7 && [ $(systemctl show -p SubState kube-apiserver | cut -d'=' -f2) != 'running' ] && exit 1",
      "[ $(systemctl show -p SubState kube-apiserver | cut -d'=' -f2) == 'running' ] && echo 'service started successfuly'",
    ]
  }
}
