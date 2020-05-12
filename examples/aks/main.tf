module "cluster" {
  source              = "github.com/cloudowski/terraform-k8s-clusters//providers/aks"
  worker_node_count   = 1
  worker_node_type    = "Standard_B2s"
  cluster_name        = "aks-1"
  k8s_version         = "1.15"
  k8s_kubeconfig      = "${path.module}/kubeconfig"
  resource_group      = "cloudowski" # must exists
  public_ssh_key_file = "~/.ssh/id_rsa.pub"
  admin_username      = "cloudowski"
}
