variable "location" {
  type        = string
  default     = "eastus"
  description = "Primary Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Enterprise default tags"
}
