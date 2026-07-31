# ------------------------------------------------------------------
# Root Orchestrator: Invoking Enterprise Modules
# ------------------------------------------------------------------

# 1. Call Networking Module (Hub & Spoke VNets)
module "networking" {
  source   = "./modules/networking"
  location = var.location
  tags     = var.tags
}

# 2. Call Compute Module (Zero Public IP VM & NSGs)
module "compute" {
  source              = "./modules/compute"
  location            = module.networking.spoke_location
  resource_group_name = module.networking.spoke_resource_group_name
  web_subnet_id       = module.networking.web_subnet_id
  tags                = var.tags
}

# 3. Call Storage Module (Storage Account & Private Endpoint)
module "storage" {
  source              = "./modules/storage"
  location            = module.networking.spoke_location
  resource_group_name = module.networking.spoke_resource_group_name
  db_subnet_id        = module.networking.db_subnet_id
  tags                = var.tags
}