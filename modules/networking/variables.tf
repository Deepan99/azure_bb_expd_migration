variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}