locals {
  # If you change paths make sure that those directories exist or create them!
  kubelet_config_dest = "/var/lib/kubelet/kubelet-config.yaml"
  kube_config_dest    = "/var/lib/kubelet/worker.kubeconfig"

  worker_cert_dest        = "/var/lib/kubelet/worker.pem"
  worker_private_key_dest = "/var/lib/kubelet/worker-key.pem"
  ca_cert_dest            = "/var/lib/kubernetes/ca.pem"
}

# Download etcd binary
resource "null_resource" "kublet_binary" {
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
      "wget -q --show-progress --https-only --timestamping 'https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubelet'",
      "chmod +x kubelet",
      "sudo mv kubelet /usr/local/bin/",
    ]
  }
}

data "template_file" "kubelet_config_template" {
  template = "${file("${path.module}/kublet-config.yaml.tpl")}"

  vars {
    POD_CIDR                = "${var.pod_cidr}"
    WORKER_CERT_PATH        = "${local.worker_cert_dest}"
    WORKER_PRIVATE_KEY_PATH = "${local.worker_private_key_dest}"
    CA_CERT_PATH            = "${local.ca_cert_dest}"
  }
}

data "template_file" "kubelet_service_template" {
  template = "${file("${path.module}/kubelet.service.tpl")}"

  vars {
    KUBELET_CONFIG_PATH = "${local.kubelet_config_dest}"
    KUBE_CONFIG_PATH    = "${local.kube_config_dest}"
  }
}

resource "local_file" "kubelet_config" {
  content  = "${data.template_file.kubelet_config_template.rendered}"
  filename = "./.generated/kubelet-config.yaml"
}

resource "local_file" "kubelet_service" {
  content  = "${data.template_file.kubelet_service_template.rendered}"
  filename = "./.generated/kubelet.service"
}

# Configure the kubelet server
resource "null_resource" "kubelet_server" {
  count = "${length(var.server_private_ips)}"

  triggers = {
    rendered_config  = "${data.template_file.kubelet_config_template.rendered}"
    rendered_service = "${data.template_file.kubelet_service_template.rendered}"
  }

  depends_on = ["local_file.kubelet_config"]

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/lib/kubelet/ /var/lib/kubernetes/",
    ]
  }

  provisioner "file" {
    content     = "${element(var.worker_certificates, count.index)}"
    destination = "${local.worker_cert_dest}"
  }

  provisioner "file" {
    content     = "${element(var.worker_private_keys, count.index)}"
    destination = "${local.worker_private_key_dest}"
  }

  provisioner "file" {
    content     = "${element(var.worker_configs, count.index)}"
    destination = "${local.kube_config_dest}"
  }

  provisioner "file" {
    content     = "${var.certificate_authority_certificate}"
    destination = "${local.ca_cert_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.kubelet_config_template.rendered}"
    destination = "${local.kubelet_config_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.kubelet_service_template.rendered}"
    destination = "/etc/systemd/system/kubelet.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable kubelet",
      "sudo systemctl start kubelet",
      "sleep 15 && [ $(systemctl show -p SubState kubelet | cut -d'=' -f2) = 'running' ]  && echo succcess",
    ]
  }
}
