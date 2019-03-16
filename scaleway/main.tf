provider "scaleway" {
  organization = "${var.scw_org}"
  token        = "${var.scw_token}"
  region       = "${var.region}"
}

data "scaleway_image" "xenial" {
  architecture = "x86_64"
  name         = "Ubuntu Xenial"
}

resource "scaleway_ip" "loadbalancer_server_ip" {
  server = "${scaleway_server.loadbalancer.id}"
}

resource "scaleway_server" "loadbalancer" {
  image          = "${data.scaleway_image.xenial.id}"
  type           = "${var.loadbalancer_type}"
  name           = "${var.prefix}-loadbalancer-server"
  security_group = "${scaleway_security_group.cluster_security_group.id}"
}

resource "scaleway_security_group" "cluster_security_group" {
  name        = "${var.prefix}-allow_me"
  description = "Cluster secutiry group"

  # security groups are sh*t so we will use ufw
  inbound_default_policy  = "accept"
  outbound_default_policy = "accept"
}

resource "scaleway_security_group_rule" "accept_me" {
  security_group = "${scaleway_security_group.cluster_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${module.ip.cidr}"
  protocol  = "TCP"
}

resource "scaleway_security_group_rule" "accept_local" {
  security_group = "${scaleway_security_group.cluster_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "10.0.0.0/8"
  protocol  = "TCP"
}

resource "scaleway_server" "master_server" {
  count               = "${var.master_count}"
  image               = "${data.scaleway_image.xenial.id}"
  type                = "${var.master_type}"
  name                = "${var.prefix}-master-${count.index}-server"
  security_group      = "${scaleway_security_group.cluster_security_group.id}"
  dynamic_ip_required = true
}

resource "scaleway_server" "worker_server" {
  count               = "${var.worker_count}"
  image               = "${data.scaleway_image.xenial.id}"
  type                = "${var.worker_type}"
  name                = "${var.prefix}-worker-${count.index}-server"
  security_group      = "${scaleway_security_group.cluster_security_group.id}"
  dynamic_ip_required = true
}

data "template_file" "firewall_init" {
  template = "${file("${path.module}/firewall-setup")}"

  vars {}
}

resource "scaleway_user_data" "loadbalancer_server_init" {
  server = "${scaleway_server.loadbalancer.id}"
  key    = "cloud-init"
  value  = "${data.template_file.firewall_init.rendered}"
}

resource "scaleway_user_data" "master_server_init" {
  count  = "${var.master_count}"
  server = "${scaleway_server.master_server.*.id[count.index]}"
  key    = "cloud-init"
  value  = "${data.template_file.firewall_init.rendered}"
}

resource "scaleway_user_data" "worker_server_init" {
  count  = "${var.worker_count}"
  server = "${scaleway_server.worker_server.*.id[count.index]}"
  key    = "cloud-init"
  value  = "${data.template_file.firewall_init.rendered}"
}

module "ip" {
  source = "../ip-module"
}

module "firewall" {
  source = "firewall-reinforce"

  my_ip                   = "${module.ip.cidr}"
  load_balancer_public_ip = "${scaleway_server.loadbalancer.public_ip}"

  server_private_ips = [
    "${scaleway_server.master_server.*.private_ip}",
    "${scaleway_server.worker_server.*.private_ip}",
  ]
}
