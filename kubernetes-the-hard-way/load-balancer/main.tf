locals {
  # If you change paths make sure that those directories exist or create them!
  nginx_config = "/etc/nginx/nginx.conf"
}

data "template_file" "nginx_config_template" {
  template = "${file("${path.module}/nginx.conf.tpl")}"

  vars {
    API_SERVER_LIST  = "${join("\n",formatlist("server %s:6443;", var.master_private_ips))}"
    ETCD_SERVER_LIST = "${join("\n",formatlist("server %s:2379;", var.master_private_ips))}"
  }
}

resource "local_file" "nginx_config" {
  content  = "${data.template_file.nginx_config_template.rendered}"
  filename = "./.generated/nginx.conf"
}

# Download etcd binary
resource "null_resource" "nginx_service" {
  triggers = {
    rendered_content = "${data.template_file.nginx_config_template.rendered}"
  }

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
    host = "${var.load_balancer_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt -y install nginx",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.nginx_config_template.rendered}"
    destination = "${local.nginx_config}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart nginx",
    ]
  }
}
