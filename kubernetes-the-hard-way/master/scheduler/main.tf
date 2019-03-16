locals {
  # If you change paths make sure that those directories exist or create them!
  scheduler_kubeconfig_dest = "/var/lib/kubernetes/kube-scheduler.kubeconfig"
  scheduler_config_dest     = "/etc/kubernetes/config/kube-scheduler.yaml"
}

# Download controller-manager binary
resource "null_resource" "scheduler_binary" {
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
      "wget -q --show-progress --https-only --timestamping 'https://storage.googleapis.com/kubernetes-release/release/${var.kubernetes_version}/bin/linux/amd64/kube-scheduler'",
      "chmod +x kube-scheduler",
      "sudo mv kube-scheduler /usr/local/bin/",
    ]
  }
}

data "template_file" "scheduler_template" {
  template = "${file("${path.module}/scheduler.tpl")}"

  vars {
    KUBE_CONFIG = "${local.scheduler_kubeconfig_dest}"
  }
}

data "template_file" "scheduler_service_template" {
  template = "${file("${path.module}/scheduler.service.tpl")}"

  vars {
    SCHEDULER_CONFIG = "${local.scheduler_config_dest}"
  }
}

resource "local_file" "scheduler_config" {
  count    = "${length(var.server_ips)}"
  content  = "${data.template_file.scheduler_service_template.rendered}"
  filename = "./.generated/${element(var.server_hostnames, count.index)}.scheduler.service"
}

resource "local_file" "scheduler" {
  count    = "${length(var.server_ips)}"
  content  = "${data.template_file.scheduler_template.rendered}"
  filename = "./.generated/${element(var.server_hostnames, count.index)}.scheduler.yaml"
}

# Configure the scheduler server
resource "null_resource" "scheduler_server" {
  count = "${length(var.server_ips)}"

  triggers = {
    config_rendered_content  = "${data.template_file.scheduler_template.rendered}"
    service_rendered_content = "${data.template_file.scheduler_service_template.rendered}"
    binary                   = "${null_resource.scheduler_binary.*.id[count.index]}"
  }

  depends_on = ["local_file.scheduler_config"]

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
    host = "${element(var.server_ips, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/lib/kubernetes/ /etc/kubernetes/config/",
    ]
  }

  provisioner "file" {
    content     = "${var.scheduler_client_config}"
    destination = "${local.scheduler_kubeconfig_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.scheduler_template.rendered}"
    destination = "${local.scheduler_config_dest}"
  }

  provisioner "file" {
    content     = "${data.template_file.scheduler_service_template.rendered}"
    destination = "/etc/systemd/system/kube-scheduler.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable kube-scheduler",
      "sudo systemctl start kube-scheduler",
      "sleep 15 && [ $(systemctl show -p SubState kube-scheduler | cut -d'=' -f2) == 'running' ] && echo succcess",
    ]
  }
}
