apiVersion: componentconfig/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "${KUBE_CONFIG}"
leaderElection:
  leaderElect: true