variable "instance_type" {
  description = "Instance type"
  default = "t2.medium"
}

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
  description = "AWS Region"
  default = "eu-west-1"
}

variable "key_path" {
  description = "SSH public key path"
}

variable "ami" {
  description = "CoreOS AMI"
}

variable "node_pwds" {
  type = "map"
}
