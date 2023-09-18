variable "prefix" {
  description = "A prefix used for all resources in this example"
  type        = string
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  type        = string
}

variable "rg" {
  description = "The Azure Resource Group in which all resources in this example should be provisioned"
  type        = string
}