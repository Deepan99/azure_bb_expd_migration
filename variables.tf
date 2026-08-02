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
    ManagedBy   = "GitHub-Actions"
  }
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM - must be provided via environment variable or secure input"
  sensitive   = true
}