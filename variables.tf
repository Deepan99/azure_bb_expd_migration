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