locals {
  # If you change paths make sure that those directories exist or create them!
  containerd_config_dest = "/etc/containerd/config.toml"
}

# Download etcd binary
resource "null_resource" "containerd_binary" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    etcd_version = "${var.runc_version}"
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
      "wget -q --show-progress --https-only --timestamping 'https://github.com/opencontainers/runc/releases/download/${var.runc_version}/runc.amd64'",
      "wget -q --show-progress --https-only --timestamping 'https://storage.googleapis.com/kubernetes-the-hard-way/runsc-50c283b9f56bb7200938d9e207355f05f79f0d17'",
      "wget -q --show-progress --https-only --timestamping 'https://github.com/containerd/containerd/releases/download/v1.2.0-rc.0/containerd-1.2.0-rc.0.linux-amd64.tar.gz'",
      "sudo tar -xvf containerd-1.2.0-rc.0.linux-amd64.tar.gz -C /",
      "sudo mv runsc-50c283b9f56bb7200938d9e207355f05f79f0d17 runsc",
      "sudo mv runc.amd64 runc",
      "chmod +x runc runsc",
      "sudo mv runc runsc /usr/local/bin/",
    ]
  }
}

data "template_file" "config_toml_template" {
  template = "${file("${path.module}/config.toml.tpl")}"
}

data "template_file" "containerd_service_template" {
  template = "${file("${path.module}/containerd.service.tpl")}"
}

resource "local_file" "config_toml" {
  content  = "${data.template_file.config_toml_template.rendered}"
  filename = "./.generated/config.toml"
}

resource "local_file" "containerd_service" {
  content  = "${data.template_file.containerd_service_template.rendered}"
  filename = "./.generated/containerd.service"
}

# Configure the etcd server
resource "null_resource" "containerd_server" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    rendered_config  = "${data.template_file.config_toml_template.rendered}"
    rendered_service = "${data.template_file.containerd_service_template.rendered}"
  }

  depends_on = ["local_file.containerd_service"]

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/containerd/",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_template.rendered}"
    destination = "${local.containerd_config_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.containerd_service_template.rendered}"
    destination = "/etc/systemd/system/containerd.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable containerd",
      "sudo systemctl start containerd",
      "sleep 25 && [ $(systemctl show -p SubState containerd | cut -d'=' -f2) = 'running' ]  && echo succcess",
    ]
  }
}
