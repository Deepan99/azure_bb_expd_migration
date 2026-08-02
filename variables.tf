variable "location" {
  type        = string
  default     = "eastus"
  description = "Target Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Enterprise tags"
  default = {
    Environment = "Production"
    ManagedBy   = "Bitbucket-Pipelines"
  }
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM"
  sensitive   = true
  default     = "EnterpriseP@ss2026!"
}