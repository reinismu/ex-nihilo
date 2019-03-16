output "config" {
  value = "${data.template_file.config_template.rendered}"
}
