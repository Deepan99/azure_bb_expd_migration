variable "location" {
  type        = string
  default     = "eastus"
  description = "Primary Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Spoke Resource Group Name"
}

variable "tags" {
  type        = map(string)
  description = "Enterprise default tags"
}
