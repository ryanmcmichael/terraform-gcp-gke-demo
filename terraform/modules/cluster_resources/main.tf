# Global resources

locals {
  main_subdomain   = terraform.workspace == "staging" ? "staging" : "default"
  client_subdomain = terraform.workspace == "staging" ? "staging-client" : "client"
}

data "google_client_config" "default" {}

data "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.region
  project  = var.project
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.main.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.main.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.main.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.main.master_auth[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.main.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.main.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
  load_config_file       = false
}

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    datadog = {
      source = "datadog/datadog"
    }
    kubernetes = {
      source  = "registry.terraform.io/hashicorp/kubernetes"
      version = "2.7.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.0"
    }
    random = {
      source = "hashicorp/random"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "docker" {
  registry_auth {
    address  = "gcr.io"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}


# Namespace

resource "kubernetes_namespace" "functions_namespace" {
  provider   = kubernetes
  depends_on = [data.google_client_config.default]
  metadata {
    name = "${terraform.workspace}-${var.functions_namespace}"
  }
}


# Ingress

resource "helm_release" "ingress_nginx" {
  depends_on = [kubernetes_namespace.functions_namespace]
  name       = "${terraform.workspace}-ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.15.2"
  namespace  = kubernetes_namespace.functions_namespace.metadata.0.name
  timeout    = 600

  set {
    name  = "controller.stats.enabled"
    value = true
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.cluster.address
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}

resource "kubernetes_ingress" "ingress" {
  depends_on             = [kubernetes_namespace.functions_namespace]
  wait_for_load_balancer = true
  metadata {
    labels = {
      app = "${terraform.workspace}-ingress-nginx"
    }
    name      = "${terraform.workspace}-functions-ingress"
    namespace = kubernetes_namespace.functions_namespace.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/$2"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout" : 3600#300
      "nginx.ingress.kubernetes.io/proxy-send-timeout" : 3600#300
      "nginx.ingress.kubernetes.io/send-timeout" : 3600#300
      "nginx.ingress.kubernetes.io/proxy-read-timeout" : 3600#300
      "nginx.ingress.kubernetes.io/use-forwarded-headers" : "true"
      "nginx.ingress.kubernetes.io/use-proxy-protocol" : "true"
      "nginx.ingress.kubernetes.io/compute-full-forwarded-for" : "true"
      "service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol" : "true"
      "nginx.ingress.kubernetes.io/use-forwarded-headers" : "true"
      "kubernetes.io/ingress.global-static-ip-name" : google_compute_address.cluster.address
      "cert-manager.io/cluster-issuer" : module.cert_manager.cluster_issuer_name
    }
  }

  spec {
  }
}


resource "google_compute_address" "cluster" {
  name = "${terraform.workspace}-cluster-ip"
}

module "cert_manager" {
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "2.4.1"

  create_namespace = false
  namespace_name   = kubernetes_namespace.functions_namespace.metadata.0.name

  cluster_issuer_email                   = var.cluster_issuer_email
  cluster_issuer_private_key_secret_name = "${terraform.workspace}-cert-secret"
}
