output "master_ip" {
  value = "${module.scaleway.master_ip}"
}

output "worker_ips" {
  value = "${module.scaleway.worker_ips}"
}
