variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "udacity-azure-webserver"
}

variable "location" {
  description = "The Azure region in which all resources in this example should be created"
  default = "East US"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    Name = "udacity-azure-webserver"
  }
}

variable "instance_count" {
  description = "Number machines to be created"
  type = number
  default = 2
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_username" {
  description = "Default username for admin"
  default = "azureuser"
}

variable "packer_resource_group" {
  description = "Resource group of the Packer image"
}

variable "packer_image_name" {
  description = "Image name of the Packer image"
}