output "controller_manager_config" {
  value = "${module.controller_manager.config}"
}

output "scheduler_client_config" {
  value = "${module.scheduler_client.config}"
}

output "worker_configs" {
  value = "${data.template_file.worker_config_template.*.rendered}"
}

output "kube_proxy_config" {
  value = "${module.proxy_client.config}"
}
