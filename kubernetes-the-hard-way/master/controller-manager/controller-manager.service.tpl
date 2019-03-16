[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
  --address=0.0.0.0 \
  --cluster-cidr=10.200.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=${CA_CERT_PATH} \
  --cluster-signing-key-file=${CA_PRIVATE_KEY_PATH} \
  --kubeconfig=${CONTROLLER_MANAGER_CONFIG_PATH} \
  --leader-elect=true \
  --root-ca-file=${CA_CERT_PATH} \
  --service-account-private-key-file=${SERVICE_ACCOUNT_PRIVATE_KEY_PATH} \
  --service-cluster-ip-range=10.32.0.0/24 \
  --use-service-account-credentials=true \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target