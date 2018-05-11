
#===== Define AWS as our provider
provider "aws" {}

#======Security Group definition
resource "aws_security_group" "default" {
  name = "terraform-sg"

  # Allow all inbound
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Enable ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#==========variable definition
variable "aws_region" {
  description = "AWS region on which we will setup the swarm cluster"
  default = "us-east-1"
}

variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-43a15f3e"
}

variable "instance_type" {
  description = "Instance type"
  default = "t2.micro"
}

variable "instance_count" {
  type    = "string"
  default = "1"
}

variable "aws_access_key_id" {
  type    = "string"
}

variable "aws_secret_access_key" {
  type    = "string"
}

variable "aws_security_token" {
  type    = "string"
}

variable "aws_default_region" {
  type    = "string"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "id_rsa.pub"
}


variable "key_name" {
  description = "SSH Public Key name"
  default = "aws_terraform"
}


variable "bootstrap_path" {
  description = "Script to install tomcat"
  default = "install-tomcat.sh"
}

#========== Resouce definition

resource "aws_key_pair" "default"{
  key_name = "${var.key_name}" 
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "web" {
  count = "${var.instance_count}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.default.id}"
  user_data = "${file("${var.bootstrap_path}")}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags {
    Name  = "Terraform-web"
  }
  
  provisioner "local-exec" {
    command = "sleep 120"
  }
  
}


output "Webip" {
  value = ["${aws_instance.web.*.public_dns}"]
}

