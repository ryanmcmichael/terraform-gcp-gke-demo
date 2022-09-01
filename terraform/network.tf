module "network" {
  source = "./modules/network"

  project = var.project
  region  = var.region
}
