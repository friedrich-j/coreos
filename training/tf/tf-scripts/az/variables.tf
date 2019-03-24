variable "id" {
  type = "string"
  default = "training"
}

variable "node_count" {
  type = "string"
  description = "Node count"
  default = 1
}

variable "region" {
  default = "northeurope"    # "eastus"
}

variable "key_path" {
  description = "SSH public key path"
}

variable "node_pwds" {
  type = "map"
}


variable "regions" {
  type = "map"
  default = {
  	"0" = "northeurope"
  	"1" = "northeurope"
  	"2" = "westeurope"
  	"3" = "westeurope"
	"4" = "eastus"
	"5" = "eastus"
	"6" = "eastus2"
	"7" = "eastus2"
	"8" = "westus"
	"9" = "westus"
	"10" = "centralus"
	"11" = "centralus"
	"12" = "northcentralus"
	"13" = "northcentralus"
	"14" = "southcentralus"
	"15" = "southcentralus"
  }
}