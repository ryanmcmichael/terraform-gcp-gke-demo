variable "project" {
  description = "The project ID"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "network" {
  description = "The VPC network created to host the cluster in"
}

variable "cluster_subnet" {
  description = "The subnetwork created to host the cluster in"
}
