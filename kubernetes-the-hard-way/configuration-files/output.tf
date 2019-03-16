output "controller_manager_config" {
  value = "${module.controller_manager.config}"
}

output "scheduler_client_config" {
  value = "${module.scheduler_client.config}"
}
