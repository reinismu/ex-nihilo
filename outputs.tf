output "master_ips" {
  value = "${module.scaleway.master_ips}"
}

output "master_private_ips" {
  value = "${module.scaleway.master_private_ips}"
}

output "worker_ips" {
  value = "${module.scaleway.worker_ips}"
}

output "worker_private_ips" {
  value = "${module.scaleway.worker_private_ips}"
}

output "test" {
  value = "${join(",",formatlist("%s=https://%s:2380",module.scaleway.worker_ips, module.scaleway.worker_private_ips))}"
}
