locals {
  script = [
    "sudo apt update",
    "sudo apt -y install ufw",
    "sudo ufw default deny",
    "sudo ufw default allow outgoing",
    "sudo ufw allow OpenSSH",
    "sudo ufw allow from 10.0.0.0/8 to any port 2379", # etcd local
    "sudo ufw allow from 10.0.0.0/8 to any port 2380", # etcd local
    "sudo ufw allow from 10.0.0.0/8 to any port 6443", # api server local
    "echo y | sudo ufw enable",
  ]
}

resource "null_resource" "load_balancer2" {
  triggers = {
    script = "${join(", ", local.script)}"
  }

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
    host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = "${local.script}"
  }
}

resource "null_resource" "server2" {
  count = "${length(var.server_private_ips)}"

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    host         = "${element(var.server_private_ips, count.index)}"
    bastion_host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = "${local.script}"
  }
}
