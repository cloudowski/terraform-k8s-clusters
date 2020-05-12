locals {
  k8s_context    = "azure-${var.cluster_name}"
  dns_prefix     = var.cluster_name
  admin_username = var.admin_username
  # a small trick to set a dependency for configure_kubeconfig script
  aks_cluster_name = regex("${var.cluster_name}", azurerm_kubernetes_cluster.main.id)
}

provider "azurerm" {
  version = "=2.9"
  features {}
}

data "azurerm_resource_group" "main" {
  name = var.resource_group
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = local.dns_prefix

  linux_profile {
    admin_username = local.admin_username

    ssh_key {
      key_data = replace(file(var.public_ssh_key_file), "\n", "")
    }
  }

  default_node_pool {
    name            = "nodepool"
    node_count      = var.worker_node_count
    vm_size         = var.worker_node_type
    os_disk_size_gb = 50
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "null_resource" "configure_kubeconfig" {
  provisioner "local-exec" {
    command = "az aks get-credentials --name ${local.aks_cluster_name} -g ${var.resource_group} --context ${local.k8s_context} --file ${var.k8s_kubeconfig}"
    environment = {
      KUBECONFIG = var.k8s_kubeconfig
    }
  }
}
