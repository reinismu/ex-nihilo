module "scaleway" {
  source = "./scaleway"

  scw_org     = "${var.scw_org}"
  scw_token   = "${var.scw_token}"
  region      = "${var.region}"
  prefix      = "${var.prefix}"
  master_type = "${var.master_type}"
  worker_type = "${var.worker_type}"
}
