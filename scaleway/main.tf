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
  count  = "${var.master_count}"
  server = "${element(scaleway_server.master_server.*.id, count.index)}"
}

resource "scaleway_server" "master_server" {
  count          = "${var.master_count}"
  image          = "${data.scaleway_image.xenial.id}"
  type           = "${var.master_type}"
  name           = "${var.prefix}-master-${count.index}-server"
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
  count          = "${var.worker_count}"
  security_group = "${scaleway_security_group.master_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${element(scaleway_server.worker_server.*.public_ip, count.index)}"
  protocol  = "TCP"
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
  count          = "${var.master_count}"
  security_group = "${scaleway_security_group.worker_security_group.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${element(scaleway_ip.master_server_ip.*.ip, count.index)}"
  protocol  = "TCP"
}

module "ip" {
  source = "../ip-module"
}
