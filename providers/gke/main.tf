locals {
  k8s_context = "gke_${var.project}_${var.gke_zones[0]}_${var.cluster_name}"
}

provider "google" {
  version = "~> 3.12"
  project = var.project
  region  = var.region
}

data "google_container_cluster" "this" {
  name = module.gke.name
  zone = var.gke_zones[0]
}

module "gcp_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.1"

  network_name = var.cluster_name
  project_id   = var.project
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "gke"
      subnet_ip             = "10.64.0.0/20"
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  secondary_ranges = {
    gke = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "10.64.16.0/20"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "10.64.32.0/20"
      }
    ]
  }
  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "<= 8.1.0"

  project_id                 = var.project
  name                       = var.cluster_name
  region                     = var.region
  zones                      = var.gke_zones
  network                    = var.cluster_name
  subnetwork                 = "gke"
  ip_range_pods              = "gke-pods"
  ip_range_services          = "gke-services"
  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  network_policy             = true
  maintenance_start_time     = "01:00"
  kubernetes_version         = var.k8s_version
  remove_default_node_pool   = true
  create_service_account     = false
  regional                   = false
  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ]

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = var.worker_node_type
      node_count         = var.worker_node_count
      min_count          = var.worker_node_count
      max_count          = 5
      local_ssd_count    = 0
      disk_size_gb       = 20
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      autoscaling        = false
      preemptible        = false
      initial_node_count = var.worker_node_count
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }
}

resource "null_resource" "configure_kubeconfig" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.gke.name} --zone=${var.gke_zones[0]} --project=${var.project}"
    environment = {
      KUBECONFIG = var.k8s_kubeconfig
    }
  }
}
