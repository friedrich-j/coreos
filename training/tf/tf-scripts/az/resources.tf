# Configure the Microsoft Azure Provider
provider "azurerm" {
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "rg_${var.id}"
    location = "${var.region}"

    tags {
        environment = "Training"
        scope = "${var.id}"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "vnet-${var.id}"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Training"
        scope = "${var.id}"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "subnet-${var.id}"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    count                        = "${var.node_count}"
    name                         = "publicIP-${var.id}${count.index}"
    location                     = "${var.regions[count.index]}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Training"
        scope = "${var.id}"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "nsg-${var.id}"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    
    security_rule {
        name                       = "all"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Training"
        scope = "${var.id}"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    count                     = "${var.node_count}"
    name                      = "nic-${var.id}${count.index}"
    location                  = "${var.regions[count.index]}"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id, count.index)}"
    }

    tags {
        environment = "Training"
        scope = "${var.id}"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
	count = "${var.node_count}"
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
	count 						= "${var.node_count}"
    name                        = "diag${element(random_id.randomId.*.hex, count.index)}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "${var.regions[count.index]}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Training"
        scope = "${var.id}"
    }
}

data "template_file" "cloud_config" {
  template = "${file("../../terraform_tmp/k8s-training.ign.tpl")}"
  vars = {
    hostname = "${var.id}${count.index}"
    pwd_hash = "${var.node_pwds[count.index]}"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    count                 = "${var.node_count}"
    name                  = "vm-${var.id}${count.index}"
    location 			  = "${var.regions[count.index]}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic.*.id, count.index)}"]
    vm_size               = "Standard_DS2_v2"

    storage_os_disk {
        name              = "disk-${var.id}${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "CoreOS"
        offer     = "CoreOS"
        sku       = "Stable"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.id}${count.index}"
        admin_username = "core"
        custom_data = "${data.template_file.cloud_config.rendered}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/core/.ssh/authorized_keys"
            key_data = "${file("${var.key_path}")}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${element(azurerm_storage_account.mystorageaccount.*.primary_blob_endpoint, count.index)}"
    }

    tags {
        environment = "Training"
        scope = "${var.id}"
    }
}


