data "template_file" "config_template" {
  template = "${file("${path.module}/configuration.tpl")}"

  vars {
    load_balancer_public_ip           = "${var.load_balancer_public_ip}"
    certificate_authority_certificate = "${base64encode(var.certificate_authority_certificate)}"
    context_user                      = "${var.context_user}"
    users_name                        = "${var.users_name}"
    client_certificate                = "${base64encode(var.client_certificate)}"
    client_private_key                = "${base64encode(var.client_private_key)}"
  }
}

resource "local_file" "config" {
  content  = "${data.template_file.config_template.rendered}"
  filename = "./.generated/${var.config_name}.kubeconfig"
}
