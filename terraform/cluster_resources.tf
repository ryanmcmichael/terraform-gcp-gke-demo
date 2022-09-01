module "cluster_resources" {
  source = "./modules/cluster_resources"

  cluster_name         = module.cluster.cluster_name
  region               = var.region
  project              = var.project
  cluster_issuer_email = var.cluster_issuer_email
  domain               = var.domain
  network              = module.network.network_id
}
