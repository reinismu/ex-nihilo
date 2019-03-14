data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

output "ip" {
  value = "${data.http.myip.body}"
}

output "cidr" {
  value = "${chomp(data.http.myip.body)}"
}
