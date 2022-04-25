provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  name_regex = "ubuntu/images/.+/ubuntu-focal-20.[0-9]{2}-amd64-server-*"
  
  filter {
        name   = "virtualization-type"
        values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}
data "aws_regions" "current" {}

resource "aws_instance" "netolo" {
  ami = data.aws_ami.ubuntu_latest.id   
  instance_type = "t2.micro" 
}

