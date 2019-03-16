output "external_ip" {
  value = "${scaleway_ip.loadbalancer_server_ip.ip}"
}

output "master_hostnames" {
  value = "${scaleway_server.master_server.*.name}"
}

output "master_private_ips" {
  value = "${scaleway_server.master_server.*.private_ip}"
}

output "master_private_dns" {
  value = "${formatlist("%s.priv.cloud.scaleway.com",scaleway_server.master_server.*.id)}"
}

output "worker_private_dns" {
  value = "${formatlist("%s.priv.cloud.scaleway.com",scaleway_server.worker_server.*.id)}"
}

output "worker_private_ips" {
  value = "${scaleway_server.worker_server.*.private_ip}"
}

output "worker_hostnames" {
  value = "${scaleway_server.worker_server.*.name}"
}
