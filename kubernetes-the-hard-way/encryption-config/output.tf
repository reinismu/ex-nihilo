output "encryption_config" {
  value     = "${data.template_file.encryption_config_template.rendered}"
  sensitive = true
}
