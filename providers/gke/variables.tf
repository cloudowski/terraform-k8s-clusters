variable "worker_node_count" {
  type = number
}

variable "worker_node_type" {
  type = string
}

variable "gke_zones" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "k8s_kubeconfig" {
  type = string
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

