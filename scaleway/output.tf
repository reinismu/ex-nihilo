output "master_ip" {
  value = "${scaleway_ip.master_server_ip.ip}"
}

output "worker_ips" {
  value = ["${scaleway_server.worker_server.*.public_ip}"]
}
