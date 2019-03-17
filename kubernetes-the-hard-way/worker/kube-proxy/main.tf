locals {
  # If you change paths make sure that those directories exist or create them!
  kube_proxy_config_dest = "/var/lib/kube-proxy/kube-proxy-config.yaml"
  kube_config_dest       = "/var/lib/kube-proxy/kube-proxy.kubeconfig"
}

# Download etcd binary
resource "null_resource" "kube_proxy_binary" {
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
      "wget -q --show-progress --https-only --timestamping 'https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-proxy'",
      "chmod +x kube-proxy",
      "sudo mv kube-proxy /usr/local/bin/",
    ]
  }
}

data "template_file" "kube_proxy_config_template" {
  template = "${file("${path.module}/kube-proxy-config.yaml.tpl")}"

  vars {
    KUBE_CONFIG_PATH = "${local.kube_config_dest}"
  }
}

data "template_file" "kube_proxy_service_template" {
  template = "${file("${path.module}/kube-proxy.service.tpl")}"

  vars {
    KUBE_PROXY_CONFIG = "${local.kube_proxy_config_dest}"
  }
}

resource "local_file" "config_yaml" {
  content  = "${data.template_file.kube_proxy_config_template.rendered}"
  filename = "./.generated/kube-proxy-config.yaml"
}

resource "local_file" "kube_proxy_service" {
  content  = "${data.template_file.kube_proxy_service_template.rendered}"
  filename = "./.generated/kube-proxy.service"
}

# Configure the kube-proxy server
resource "null_resource" "kube_proxy_server" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    rendered_config  = "${data.template_file.kube_proxy_config_template.rendered}"
    rendered_service = "${data.template_file.kube_proxy_service_template.rendered}"
  }

  depends_on = ["local_file.kube_proxy_service"]

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/lib/kube-proxy/",
    ]
  }

  provisioner "file" {
    content     = "${var.kube_proxy_config}"
    destination = "${local.kube_config_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.kube_proxy_config_template.rendered}"
    destination = "${local.kube_proxy_config_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.kube_proxy_service_template.rendered}"
    destination = "/etc/systemd/system/kube-proxy.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable kube-proxy",
      "sudo systemctl start kube-proxy",
      "sleep 15 && [ $(systemctl show -p SubState kube-proxy | cut -d'=' -f2) = 'running' ]  && echo succcess",
    ]
  }
}
