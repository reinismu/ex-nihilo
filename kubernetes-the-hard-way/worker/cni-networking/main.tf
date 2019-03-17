locals {
  # If you change paths make sure that those directories exist or create them!
  bridge_conf_dest   = "/etc/cni/net.d/10-bridge.conf"
  loopback_conf_dest = "/etc/cni/net.d/99-loopback.conf"
}

# Download etcd binary
resource "null_resource" "cni_binary" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    etcd_version = "${var.cni_version}"
  }

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install socat conntrack ipset",
      "wget -q --show-progress --https-only --timestamping 'https://github.com/containernetworking/plugins/releases/download/${var.cni_version}/cni-plugins-amd64-${var.cni_version}.tgz'",
      "sudo mkdir -p /opt/cni/bin/",
      "sudo tar -xvf cni-plugins-amd64-${var.cni_version}.tgz -C /opt/cni/bin/",
    ]
  }
}

data "template_file" "bridge_conf_template" {
  count    = "${length(var.server_private_ips)}"
  template = "${file("${path.module}/10-bridge.conf.tpl")}"

  vars {
    POD_CIDR = "${format(var.pod_cidr_mask, count.index)}"
  }
}

data "template_file" "loopback_conf_template" {
  template = "${file("${path.module}/99-loopback.conf.tpl")}"
}

resource "local_file" "bridge_conf" {
  content  = "${data.template_file.bridge_conf_template.*.rendered[count.index]}"
  filename = "./.generated/10-bridge.conf"
}

resource "local_file" "loopback_conf" {
  content  = "${data.template_file.loopback_conf_template.rendered}"
  filename = "./.generated/99-loopback.conf"
}

# Configure the etcd server
resource "null_resource" "cni_server" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    rendered_config  = "${data.template_file.bridge_conf_template.*.rendered[count.index]}"
    rendered_service = "${data.template_file.loopback_conf_template.id}"
  }

  depends_on = ["local_file.bridge_conf"]

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/cni/net.d/",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.bridge_conf_template.*.rendered[count.index]}"
    destination = "${local.bridge_conf_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.loopback_conf_template.rendered}"
    destination = "${local.loopback_conf_dest}"
  }
}
