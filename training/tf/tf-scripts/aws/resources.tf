provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "default" {
  key_name = "${var.id}"
  public_key = "${file("${var.key_path}")}"
}

data "template_file" "cloud_config" {
  template = "${file("../../terraform_tmp/k8s-training.ign.tpl")}"
  vars = {
    hostname = "${var.id}${count.index}"
    pwd_hash = "${var.node_pwds[count.index]}"
  }
}

resource "aws_instance" "nodes" {
  count = "${var.node_count}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.default.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  user_data = "${data.template_file.cloud_config.rendered}" 
  
  root_block_device {
    volume_type = "gp2"
    volume_size = "35"
  }

  tags {
	Name = "${var.id} ${count.index + 1}"
	Scope = "${var.id}"
	Purpose = "training"
  }
}
