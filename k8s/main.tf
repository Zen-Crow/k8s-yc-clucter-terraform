### Datasource ###
data "yandex_client_config" "client" {}

### Local variables ###
locals {
  folder_id           = var.folder_id != null ? data.yandex_client_config.client.folder_id : var.cloud_id
  k8s_service_account = "k8s-service-account"
  k8s_cluster_name    = "k8s-zonal-master"
  k8s_node_group_name = "k8s-zonal-node"
  kms_key_name        = "kms-key"
  log_group_name      = "k8s-logging-group"
}

### K8s Zonal Cluster ###
resource "yandex_kubernetes_cluster" "k8s-zonal" {
  name       = local.k8s_cluster_name
  network_id = module.all-zones-vpc.vpc_network_id

  cluster_ipv4_range       = "172.17.0.0/16"
  service_ipv4_range       = "172.18.0.0/16"
  node_ipv4_cidr_mask_size = 24
  network_policy_provider  = "CALICO"


  master {
    master_location {
      zone      = element(module.all-zones-vpc.zones, 0)
      subnet_id = element(module.all-zones-vpc.subnet_id, 0)
    }

    public_ip          = true
    security_group_ids = [module.all-zones-vpc.security_group_id]

    master_logging {
      enabled                    = true
      log_group_id               = yandex_logging_group.logging-group.id
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }

  }
  service_account_id      = yandex_iam_service_account.myaccount.id
  node_service_account_id = yandex_iam_service_account.myaccount.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter,
    yandex_resourcemanager_folder_iam_member.logging-writer
  ]
  release_channel = "REGULAR"

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }

}

### K8s Node group ###
resource "yandex_kubernetes_node_group" "my_node_group" {
  name        = local.k8s_node_group_name
  description = "description"
  version     = "1.27"
  cluster_id  = yandex_kubernetes_cluster.k8s-zonal.id

  node_labels = {
    "label1" = "k8s_node_group1"
  }

  instance_template {
    platform_id = "standard-v3"
    resources {
      core_fraction = 50
      memory        = 2
      cores         = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    network_interface {
      subnet_ids         = [element(module.all-zones-vpc.subnet_id, 0)]
      security_group_ids = [module.all-zones-vpc.security_group_id]
      nat                = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 3
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
    maintenance_window {
      start_time = "22:00"
      duration   = "10h"
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }
}

resource "yandex_logging_group" "logging-group" {
  description = "Cloud Logging group"
  name        = local.log_group_name
  folder_id   = local.folder_id
}

### K8s Service Account ###
resource "yandex_iam_service_account" "myaccount" {
  name        = local.k8s_service_account
  description = "K8S zonal service account"
}

### Роль "k8s.clusters.agent" ###
resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  folder_id = local.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### Роль "vpc.publicAdmin" ###
resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  folder_id = local.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### Роль "container-registry.images.puller" ###
resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### Роль "kms.keys.encrypterDecrypter" ###
resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  folder_id = local.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### Yandex KMS key for encryption and decryption of Kubernetes secrets ###
resource "yandex_kms_symmetric_key" "kms-key" {
  name              = local.kms_key_name
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

### Роль "logging.writer" ###
resource "yandex_resourcemanager_folder_iam_member" "logging-writer" {
  folder_id = local.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### Роль Load Balancer Admin ###
resource "yandex_resourcemanager_folder_iam_member" "load-balancer-admin" {
  folder_id = local.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### РольVpc privateAdmin ###
resource "yandex_resourcemanager_folder_iam_member" "vpc-privateAdmin" {
  folder_id = local.folder_id
  role      = "vpc.privateAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### Роль "compute.admin" ###
resource "yandex_resourcemanager_folder_iam_member" "compute-admin" {
  folder_id = local.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}

### Роль "k8s.tunnelClusters.agent" ###
resource "yandex_resourcemanager_folder_iam_member" "tunnelClusterAgent" {
  folder_id = local.folder_id
  role      = "k8s.tunnelClusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.myaccount.id}"
}
