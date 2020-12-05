provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vn" {
  name                = "${var.prefix}-virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet"{
  name                = "${var.prefix}-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name= azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-network-security-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags                         =  var.tags
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_network_interface" "ni" {
  count               = var.instance_count
  name                = "${var.prefix}-ni-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
  }

  tags                =  var.tags
}

resource "azurerm_network_interface_security_group_association" "nisga" {
  count                     = var.instance_count
  network_interface_id      = azurerm_network_interface.ni[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lbpip" {
  name                = "${var.prefix}-load-balancer-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-load-balancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }

  tags                = var.tags
}

resource "azurerm_lb_backend_address_pool" "lbbap" {
  name                = "BackendAddressPool"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_nat_rule" "natRule" {
  name                           = "HTTPSAccess"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 338
  backend_port                   = 338
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "nibapa" {
  count                   = var.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbbap.id
  ip_configuration_name   = "Configuration"
  network_interface_id    = element(azurerm_network_interface.ni.*.id, count.index)
}

resource "azurerm_availability_set" "aset" {
  name                = "${var.prefix}-availability_set"
  location            =  azurerm_resource_group.rg.location
  resource_group_name =  azurerm_resource_group.rg.name
  managed             =  true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  tags                =  var.tags
}

data "azurerm_resource_group" "packer_rg" {
  name = var.packer_resource_group
}

data "azurerm_image" "packer_image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.packer_rg.name
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.instance_count
  name                = "${var.prefix}-vm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  source_image_id     = data.azurerm_image.packer_image.id
  admin_username      = "ubuntu"
  disable_password_authentication = false
  admin_password      = "P@ssw0rd1234!"
  availability_set_id   = azurerm_availability_set.aset.id
  network_interface_ids = [
    azurerm_network_interface.ni[count.index].id
  ]

#   admin_ssh_key {
#     username   = "ubuntu"
#     public_key = file("~/.ssh/my_azure.pub")
#   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = var.tags
}

resource "azurerm_managed_disk" "data" {
  count                           = var.instance_count
  name                            = "${var.prefix}-md-${count.index}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  create_option                   = "Empty"
  disk_size_gb                    = 10
  storage_account_type            = "Standard_LRS"
  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.instance_count
  virtual_machine_id = azurerm_linux_virtual_machine.vm[count.index].id
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  lun                = 10
  caching            = "ReadWrite"
}