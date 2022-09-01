output "cluster_name" {
  description = "Cluster name"
  value       = google_container_cluster.main.name
}
