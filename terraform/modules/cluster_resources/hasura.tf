/*# Networking

resource "google_compute_global_address" "hasura_private_ip" {
  provider = google-beta

  name          = "${terraform.workspace}-hasura-private-ip"
  project       = var.project
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network
}

resource "google_service_networking_connection" "hasura_private_vpc_connection" {
  provider = google-beta

  network                 = var.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.hasura_private_ip.name]
}


# Database

resource "random_id" "hasura_db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "hasura_instance" {
  provider = google-beta

  name             = "${terraform.workspace}-hasura-${random_id.hasura_db_name_suffix.hex}"
  project          = var.project
  region           = var.region
  database_version = "POSTGRES_12"

  depends_on = [google_service_networking_connection.hasura_private_vpc_connection]

  settings {
    tier = "db-g1-small"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }
  }
}

resource "google_sql_database" "hasura" {
  name     = "hasura"
  project  = var.project
  instance = google_sql_database_instance.hasura_instance.name
}

data "google_secret_manager_secret_version" "hasura_password" {
  secret = "${terraform.workspace}-hasura-db-password"
}

resource "google_sql_user" "hasura_user" {
  name     = "postgres"
  project  = var.project
  instance = google_sql_database_instance.hasura_instance.name
  password = data.google_secret_manager_secret_version.hasura_password.secret_data
}


# Hasura

resource "helm_release" "hasura" {
  depends_on = [kubernetes_namespace.functions_namespace]
  name       = "${terraform.workspace}-hasura"
  chart      = "https://charts.platy.plus/charts/hasura-1.1.6.tgz"
  namespace  = kubernetes_namespace.functions_namespace.metadata.0.name
  version    = "2.2.0"
  timeout    = 600

  set {
    name  = "imageConfig.tag"
    value = "v2.2.0"
  }

  set {
    name  = "global.ingress.enabled"
    value = false
  }

  set {
    name  = "ingress.enabled"
    value = false
  }

  set {
    name  = "postgresql.enabled"
    value = false
  }

  set {
    name  = "pgClient.external.enabled"
    value = true
  }

  #TODO: find this address using terraform
  set {
    name  = "pgClient.external.host"
    value = "10.90.0.5"
  }

  set {
    name  = "pgClient.external.password"
    value = data.google_secret_manager_secret_version.hasura_password.secret_data
  }

  set {
    name  = "pgClient.external.port"
    value = 5432
  }

  set {
    name  = "postgresql.service.port"
    value = 5432
  }

  set {
    name  = "pgClient.external.username"
    value = "postgres"
  }

  set {
    name  = "pgClient.external.database"
    value = "hasura"
  }

  set {
    name  = "console.enabled"
    value = true
  }
}*/
