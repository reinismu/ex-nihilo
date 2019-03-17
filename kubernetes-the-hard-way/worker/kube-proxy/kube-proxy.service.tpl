[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \
  --config=${KUBE_PROXY_CONFIG}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target