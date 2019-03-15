apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${certificate_authority_certificate}
    server: https://${load_balancer_public_ip}:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: ${context_user}
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: ${users_name}
  user:
    as-user-extra: {}
    client-certificate-data: ${client_certificate}
    client-key-data: ${client_private_key}