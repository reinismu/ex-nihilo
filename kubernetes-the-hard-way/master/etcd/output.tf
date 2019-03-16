output "etcd_done" {
  value = "${null_resource.etcd_server.0.id}"
}
