data "template_file" "worker_config_template" {
  template = "${file("${path.module}/worker-configuration.tpl")}"

  count = "${length(var.worker_server_hostnames)}"

  vars {
    certificate_authority_certificate = "${base64encode(var.certificate_authority_certificate)}"
    worker_server_certificate         = "${base64encode(element(var.worker_server_certificates, count.index))}"
    worker_server_private_key         = "${base64encode(element(var.worker_server_private_keys, count.index))}"
    load_balancer_private_ip          = "${var.load_balancer_private_ip}"
    worker_hostname                   = "${element(var.worker_server_hostnames, count.index)}"
  }
}

resource "local_file" "worker_config" {
  count    = "${length(var.worker_server_hostnames)}"
  content  = "${data.template_file.worker_config_template.*.rendered[count.index]}"
  filename = "./.generated/${element(var.worker_server_hostnames, count.index)}.kubeconfig"
}
