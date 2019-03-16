[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \
  --name ${ETCD_NAME} \
  --cert-file=${API_SERVER_CERT_PATH} \
  --key-file=${API_SERVER_PRIVATE_KEY_PATH} \
  --peer-cert-file=${API_SERVER_CERT_PATH} \
  --peer-key-file=${API_SERVER_PRIVATE_KEY_PATH}  \
  --trusted-ca-file=${CA_CERT_PATH} \
  --peer-trusted-ca-file=${CA_CERT_PATH} \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${PRIVATE_IP}:2380 \
  --listen-peer-urls https://${PRIVATE_IP}:2380 \
  --listen-client-urls https://${PRIVATE_IP}:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://${PRIVATE_IP}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster ${CLUSTER_CONFIGURATION} \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target