resource "google_container_cluster" "main" {
  provider = google

  name     = "${terraform.workspace}-cluster"
  location = var.region

  network    = var.network
  subnetwork = var.cluster_subnet

  ip_allocation_policy {
    cluster_secondary_range_name  = "${terraform.workspace}-cluster-pods-range"
    services_secondary_range_name = "${terraform.workspace}-cluster-services-range"
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    cloudrun_config { disabled = true }
    http_load_balancing { disabled = false }
    horizontal_pod_autoscaling { disabled = false }
  }

  release_channel { channel = "REGULAR" }
  vertical_pod_autoscaling { enabled = true }

  enable_tpu              = false
  enable_legacy_abac      = false
  enable_kubernetes_alpha = false

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  enable_autopilot   = false
  initial_node_count = 1
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/datastore",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/taskqueue",
      "https://www.googleapis.com/auth/userinfo.email"
    ]
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

resource "google_container_node_pool" "e2_standard_4_workload_pool" {
  name               = "${terraform.workspace}-e2-standard-4-workload-pool"
  cluster            = google_container_cluster.main.name
  location           = var.region
  project            = var.project
  provider           = google
  initial_node_count = 1

  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }

  node_config {
    machine_type = "e2-standard-8"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/datastore",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/taskqueue",
      "https://www.googleapis.com/auth/userinfo.email"
    ]
  }
}
