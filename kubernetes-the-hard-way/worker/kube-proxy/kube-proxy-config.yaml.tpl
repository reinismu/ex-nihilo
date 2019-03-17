kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "${KUBE_CONFIG_PATH}"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"