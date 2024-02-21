variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
}

variable "client_secret" {
  description = "Client secret of service principal to be used for creating resources"
  type        = string
}
variable "subscription_id" {
  description = "ID of Subcsription where resources are to be created"
  type        = string
}
variable "tenant_id" {
  description = "ID Tenant of where resources are to be created"
  type        = string
}
variable "client_id" {
  description = "Client ID of service principal to be used for creating resources"
  type        = string
}
