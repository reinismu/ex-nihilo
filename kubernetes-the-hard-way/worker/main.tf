module "containerd" {
  source = "containerd"

  ssh_user                = "${var.ssh_user}"
  load_balancer_public_ip = "${var.load_balancer_public_ip}"
  server_private_ips      = "${var.server_private_ips}"
}
