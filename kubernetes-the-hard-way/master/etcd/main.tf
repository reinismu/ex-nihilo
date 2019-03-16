locals {
  # If you change paths make sure that those directories exist or create them!
  ca_cert_dest                = "/etc/etcd/ca.pem"
  api_server_cert_dest        = "/etc/etcd/api-server.pem"
  api_server_private_key_dest = "/etc/etcd/api-server-key.pem"
}

# Download etcd binary
resource "null_resource" "etcd_binary" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    etcd_version = "${var.etcd_version}"
  }

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "wget -q --show-progress --https-only --timestamping 'https://github.com/coreos/etcd/releases/download/${var.etcd_version}/etcd-${var.etcd_version}-linux-amd64.tar.gz'",
      "tar -xvf etcd-${var.etcd_version}-linux-amd64.tar.gz",
      "sudo mv etcd-${var.etcd_version}-linux-amd64/etcd* /usr/local/bin/",
    ]
  }
}

data "template_file" "etcd_service_template" {
  count = "${length(var.server_private_ips)}"

  template = "${file("${path.module}/etcd.service.tpl")}"

  vars {
    ETCD_NAME                   = "${element(var.server_hostnames, count.index)}"
    PRIVATE_IP                  = "${element(var.server_private_ips, count.index)}"
    API_SERVER_CERT_PATH        = "${local.api_server_cert_dest}"
    API_SERVER_PRIVATE_KEY_PATH = "${local.api_server_private_key_dest}"
    CA_CERT_PATH                = "${local.ca_cert_dest}"
    CLUSTER_CONFIGURATION       = "${join(",",formatlist("%s=https://%s:2380",var.server_hostnames, var.server_private_ips))}"
  }
}

resource "local_file" "etcd_config" {
  count    = "${length(var.server_private_ips)}"
  content  = "${data.template_file.etcd_service_template.*.rendered[count.index]}"
  filename = "./.generated/${element(var.server_hostnames, count.index)}.etcd.service"
}

# Configure the etcd server
resource "null_resource" "etcd_server" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    rendered_content = "${data.template_file.etcd_service_template.*.rendered[count.index]}"
    binary           = "${null_resource.etcd_binary.*.id[count.index]}"
  }

  depends_on = ["local_file.etcd_config"]

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/etcd /var/lib/etcd",
    ]
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
    content     = "${data.template_file.etcd_service_template.*.rendered[count.index]}"
    destination = "/etc/systemd/system/etcd.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable etcd",
      "sudo systemctl start etcd",
      "sudo ETCDCTL_API=3 etcdctl member list --endpoints=https://127.0.0.1:2379 --cacert=${local.ca_cert_dest} --cert=${local.api_server_cert_dest} --key=${local.api_server_private_key_dest}",
    ]
  }
}
