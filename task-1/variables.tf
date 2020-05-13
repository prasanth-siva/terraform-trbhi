variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "subnet" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "subnet_names" {
  description = "The address prefix to use for the subnet."
}

variable "environment" {
  description = "The environment in which the resources need to be created."
}

variable "staging" { type = map }

variable "admin_username" {}

variable "admin_password" {}
