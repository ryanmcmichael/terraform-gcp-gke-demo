output "network_name" {
  description = "Network name"
  value       = google_compute_network.network.name
}

output "cluster_subnet_name" {
  description = "Cluster subnet name"
  value       = google_compute_subnetwork.cluster.name
}

output "network_id" {
  description = "Network ID"
  value       = google_compute_network.network.id
}
