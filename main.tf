module "scaleway" {
  source = "./scaleway"

  scw_org     = "${var.scw_org}"
  scw_token   = "${var.scw_token}"
  region      = "${var.region}"
  prefix      = "${var.prefix}"
  master_type = "${var.master_type}"
  worker_type = "${var.worker_type}"

  master_count = "${var.master_count}"
  worker_count = "${var.worker_count}"
}

module "kubernetes" {
  source = "kubernetes-the-hard-way"

  ssh_private_key         = "${var.ssh_private_key}"
  ssh_user                = "root"
  load_balancer_public_ip = "${module.scaleway.external_ip}"

  master_server_hostnames   = "${module.scaleway.master_hostnames}"
  master_server_private_ips = "${module.scaleway.master_private_ips}"

  worker_server_hostnames   = "${module.scaleway.worker_hostnames}"
  worker_server_private_ips = "${module.scaleway.worker_private_ips}"
}
