locals {
  # If you change paths make sure that those directories exist or create them!
  ca_cert_dest                     = "/var/lib/kubernetes/ca.pem"
  ca_private_key_dest              = "/var/lib/kubernetes/ca-key.pem"
  controller_manager_config_dest   = "/var/lib/kubernetes/kube-controller-manager.kubeconfig"
  service_account_private_key_dest = "/var/lib/kubernetes/service-account-key.pem"
}

# Download controller-manager binary
resource "null_resource" "controller_manager_binary" {
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
      "wget -q --show-progress --https-only --timestamping 'https://storage.googleapis.com/kubernetes-release/release/${var.kubernetes_version}/bin/linux/amd64/kube-controller-manager'",
      "chmod +x kube-controller-manager",
      "sudo mv kube-controller-manager /usr/local/bin/",
    ]
  }
}

data "template_file" "controller_manager_service_template" {
  template = "${file("${path.module}/controller-manager.service.tpl")}"

  vars {
    CA_CERT_PATH                     = "${local.ca_cert_dest}"
    CA_PRIVATE_KEY_PATH              = "${local.ca_private_key_dest}"
    CONTROLLER_MANAGER_CONFIG_PATH   = "${local.controller_manager_config_dest}"
    SERVICE_ACCOUNT_PRIVATE_KEY_PATH = "${local.service_account_private_key_dest}"
  }
}

resource "local_file" "controller_manager_config" {
  count    = "${length(var.server_ips)}"
  content  = "${data.template_file.controller_manager_service_template.rendered}"
  filename = "./.generated/${element(var.server_hostnames, count.index)}.controller_manager.service"
}

# Configure the controller_manager server
resource "null_resource" "controller_manager_server" {
  count = "${length(var.server_ips)}"

  triggers = {
    rendered_content = "${data.template_file.controller_manager_service_template.rendered}"
    binary           = "${null_resource.controller_manager_binary.*.id[count.index]}"
  }

  depends_on = ["local_file.controller_manager_config"]

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
    content     = "${var.certificate_authority_certificate}"
    destination = "${local.ca_cert_dest}"
  }

  provisioner "file" {
    content     = "${var.certificate_authority_private_key_pem}"
    destination = "${local.ca_private_key_dest}"
  }

  provisioner "file" {
    content     = "${var.controller_manager_config}"
    destination = "${local.controller_manager_config_dest}"
  }

  provisioner "file" {
    content     = "${var.service_account_private_key_pem}"
    destination = "${local.service_account_private_key_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.controller_manager_service_template.rendered}"
    destination = "/etc/systemd/system/kube-controller-manager.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable kube-controller-manager",
      "sudo systemctl start kube-controller-manager",
      "sleep 15 && [ $(systemctl show -p SubState kube-controller-manager | cut -d'=' -f2) != 'running' ] && exit 1",
    ]
  }
}
