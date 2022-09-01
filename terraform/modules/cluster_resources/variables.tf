variable "cluster_name" {
  description = "GKE cluster name"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "project" {
  description = "The project ID"
}

variable "functions_namespace" {
  description = "The namespace for cluster functions"
  default     = "functions-namespace"
}

variable "service_port" {
  description = "The service port for cluster containers"
  default     = 8080
}

variable "cluster_issuer_email" {
  description = "The email for cluster cert issuer"
}

variable "network" {
  description = "The VPC network created to host the cluster in"
}

variable "domain" {
  description = "The cluster domain"
}
