output "k8s_connection" {
    value = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.k8s-zonal.id} --external"
}

output "check_connection" {
  value = "kubectl cluster-info"
}