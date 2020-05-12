module "cluster" {
  source            = "github.com/cloudowski/terraform-k8s-clusters//providers/do"
  worker_node_count = 2
  worker_node_type  = "s-2vcpu-2gb"
  cluster_name      = "do-fra1-1"
  k8s_version       = "1.15"
  region            = "fra1"
  k8s_kubeconfig    = "${path.module}/kubeconfig"
}
