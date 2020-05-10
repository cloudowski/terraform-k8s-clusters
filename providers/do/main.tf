provider "digitalocean" {
}

data "digitalocean_kubernetes_versions" "this" {
  version_prefix = "${var.k8s_version}."
}

resource "digitalocean_kubernetes_cluster" "this" {
  name    = var.cluster_name
  region  = var.region
  version = data.digitalocean_kubernetes_versions.this.latest_version

  node_pool {
    name       = "autoscale-worker-pool"
    size       = var.worker_node_type
    auto_scale = false
    node_count = var.worker_node_count
    # auto_scale = true
    # min_nodes  = var.worker_node_count
    # max_nodes  = 4
  }
}

resource "null_resource" "configure_kubeconfig" {
  provisioner "local-exec" {
    command = "doctl kubernetes cluster kubeconfig save ${digitalocean_kubernetes_cluster.this.id}"
    environment = {
      KUBECONFIG = var.k8s_kubeconfig
    }
  }
}
