resource "google_compute_network" "network" {
  provider                = google
  name                    = "${terraform.workspace}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cluster" {
  provider                 = google
  name                     = "${terraform.workspace}-cluster-subnet"
  network                  = google_compute_network.network.self_link
  private_ip_google_access = true

  ip_cidr_range = "10.10.0.0/16"

  secondary_ip_range {
    range_name    = "${terraform.workspace}-cluster-pods-range"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "${terraform.workspace}-cluster-services-range"
    ip_cidr_range = "10.30.0.0/16"
  }

  secondary_ip_range {
    ip_cidr_range = "10.143.0.0/22"
    range_name    = "xxxxx"
  }

  secondary_ip_range {
    ip_cidr_range = "10.142.128.0/17"
    range_name    = "xxxxx"
  }

  log_config {
    aggregation_interval = "INTERVAL_15_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "router" {
  name    = "${terraform.workspace}-router"
  project = var.project
  region  = var.region
  network = google_compute_network.network.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "${terraform.workspace}-nat"
  project                            = var.project
  region                             = var.region
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}
