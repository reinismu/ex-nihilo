[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
  --advertise-address=${PRIVATE_IP} \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=0.0.0.0 \
  --client-ca-file=${CA_CERT_PATH} \
  --enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --enable-swagger-ui=true \
  --etcd-cafile=${CA_CERT_PATH}  \
  --etcd-certfile=${API_SERVER_CERT_PATH} \
  --etcd-keyfile=${API_SERVER_PRIVATE_KEY_PATH} \
  --etcd-servers=${ETCD_SERVER_LIST} \
  --event-ttl=1h \
  --experimental-encryption-provider-config=${ENCRYPTION_CONFIG} \
  --kubelet-certificate-authority=${CA_CERT_PATH} \
  --kubelet-client-certificate=${API_SERVER_CERT_PATH} \
  --kubelet-client-key=${API_SERVER_PRIVATE_KEY_PATH} \
  --kubelet-https=true \
  --runtime-config=api/all \
  --service-account-key-file=${SERVICE_ACCOUNT_CERT_PATH} \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=${API_SERVER_CERT_PATH} \
  --tls-private-key-file=${API_SERVER_PRIVATE_KEY_PATH} \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target