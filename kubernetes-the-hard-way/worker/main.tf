module "cni_netwokring" {
  source = "cni-networking"

  ssh_user                = "${var.ssh_user}"
  load_balancer_public_ip = "${var.load_balancer_public_ip}"
  server_private_ips      = "${var.server_private_ips}"
  pod_cidr_mask               = "${var.pod_cidr_mask}"
}

module "containerd" {
  source = "containerd"

  ssh_user                = "${var.ssh_user}"
  load_balancer_public_ip = "${var.load_balancer_public_ip}"
  server_private_ips      = "${var.server_private_ips}"
}

module "kubelet" {
  source = "kubelet"

  ssh_user                          = "${var.ssh_user}"
  load_balancer_public_ip           = "${var.load_balancer_public_ip}"
  server_private_ips                = "${var.server_private_ips}"
  certificate_authority_certificate = "${var.certificate_authority_certificate}"
  worker_certificates               = "${var.worker_certificates}"
  worker_private_keys               = "${var.worker_private_keys}"
  worker_configs                    = "${var.worker_configs}"
  pod_cidr_mask               = "${var.pod_cidr_mask}"
}

module "kube_proxy" {
  source = "kube-proxy"

  ssh_user                = "${var.ssh_user}"
  load_balancer_public_ip = "${var.load_balancer_public_ip}"
  server_private_ips      = "${var.server_private_ips}"
  kube_proxy_config       = "${var.kube_proxy_config}"
}
