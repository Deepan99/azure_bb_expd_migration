variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "db_subnet_id" {
  type        = string
  description = "Database subnet ID"
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network ID for DNS zone link"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}