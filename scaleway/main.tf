provider "scaleway" {
  organization = "${var.scw_org}"
  token        = "${var.scw_token}"
  region       = "${var.region}"
}

data "scaleway_image" "xenial" {
  architecture = "x86_64"
  name         = "Ubuntu Xenial"
}

resource "scaleway_ip" "master_server_ip" {
  server = "${scaleway_server.master_server.id}"
}

resource "scaleway_server" "master_server" {
  count          = "1"
  image          = "${data.scaleway_image.xenial.id}"
  type           = "${var.master_type}"
  name           = "${var.prefix}-master-server"
  security_group = "${scaleway_security_group.master_security_group.id}"
}

resource "scaleway_security_group" "master_security_group" {
  name        = "${var.prefix}-master-allow_me_and_workers"
  description = "allow me and workers to connect"
}

resource "scaleway_security_group_rule" "master_accept_me" {
  security_group = "${scaleway_security_group.master_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${module.ip.cidr}"
  protocol  = "TCP"
}

resource "scaleway_security_group_rule" "master_accept_workers" {
  security_group = "${scaleway_security_group.master_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${element(scaleway_server.worker_server.*.public_ip, count.index)}"
  protocol  = "TCP"

  count = "${var.worker_count}"
}

resource "scaleway_server" "worker_server" {
  count               = "${var.worker_count}"
  image               = "${data.scaleway_image.xenial.id}"
  type                = "${var.worker_type}"
  name                = "${var.prefix}-worker-${count.index}-server"
  security_group      = "${scaleway_security_group.worker_security_group.id}"
  dynamic_ip_required = true
}

resource "scaleway_security_group" "worker_security_group" {
  name        = "${var.prefix}-worker-allow_me_and_master"
  description = "allow only me for inbound"
}

resource "scaleway_security_group_rule" "worker_accept_me" {
  security_group = "${scaleway_security_group.worker_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${module.ip.cidr}"
  protocol  = "TCP"
}

resource "scaleway_security_group_rule" "worker_accept_master" {
  security_group = "${scaleway_security_group.worker_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${scaleway_ip.master_server_ip.ip}"
  protocol  = "TCP"
}

module "ip" {
  source = "../ip-module"
}
