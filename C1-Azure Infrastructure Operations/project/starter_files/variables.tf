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

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "udacity-azure-webserver-resource-group"
}

variable "instance_count" {
  description = "Number machines to be created"
  type = number
  default = 2
}

variable "packer_resource_group" {
  description = "Resource group of the Packer image"
  default = "packer-rg"
}

variable "packer_image_name" {
  description = "Image name of the Packer image"
  default = "my-packer-image"
}