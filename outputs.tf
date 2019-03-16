output "external_ip" {
  value = "${module.scaleway.external_ip}"
}

output "master_private_ips" {
  value = "${module.scaleway.master_private_ips}"
}

output "worker_private_ips" {
  value = "${module.scaleway.worker_private_ips}"
}
