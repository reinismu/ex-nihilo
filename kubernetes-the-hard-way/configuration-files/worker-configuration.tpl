apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${certificate_authority_certificate}
    server: https://${load_balancer_public_ip}:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: system:node:${worker_hostname}
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: system:node:${worker_hostname}
  user:
    as-user-extra: {}
    client-certificate-data: ${worker_server_certificate}
    client-key-data: ${worker_server_private_key}