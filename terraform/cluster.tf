module "cluster" {
  source = "./modules/cluster"

  project        = var.project
  region         = var.region
  network        = module.network.network_name
  cluster_subnet = module.network.cluster_subnet_name
}
