resource "random_string" "encryption_key" {
  length = 32
}

data "template_file" "encryption_config_template" {
  template = "${file("${path.module}/encryption_config.tpl")}"

  vars {
    encryption_key = "${base64encode(random_string.encryption_key.result)}"
  }
}

resource "local_file" "encryption_config" {
  content  = "${data.template_file.encryption_config_template.rendered}"
  filename = "./.generated/encryption-config.yaml"
}
