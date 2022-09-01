variable "project" {
  type        = string
  description = "The GCP project name"
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "zone" {
  type        = string
  description = "The GCP zone"
}

variable "archive_directory" {
  type        = string
  description = "A directory for storing file archives"
  default     = ".archive"
}

variable "cluster_issuer_email" {
  description = "The email for cluster cert issuer"
}

variable "domain" {
  description = "The cluster domain"
}
