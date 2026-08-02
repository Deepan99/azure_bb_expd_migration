variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "web_subnet_id" {
  type        = string
  description = "Web subnet ID"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM"
  sensitive   = true
}