# atlantis-test 5555
# atlantis-test 11
# atlantis-test 22
# test1
# test3
provider "aws" {
  region = "us-east-1"
}

#terraform {
#  backend "s3" {
#    bucket = "netos3"
#    key    = "network/terraform.tfstate"
#    region = "us-east-1"
#    dynamodb_table = "terraform-lock"
#  }
#}

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
data "aws_region" "current" {}

locals {
  instance_type_map = {
    stage = "t3.micro"
    prod = "t2.micro"
  }
  instance_count_map = {
    stage = 1
    prod = 2
  }
  instance_common_maps = {
    stage = {
      "0" = "t3.micro"
    } 
    prod = {
      "0" = "t2.micro",
      "1" = "t2.micro"
    }   
  }
}

resource "aws_instance" "netolo" {
  ami = data.aws_ami.ubuntu_latest.id   
  instance_type = local.instance_type_map[terraform.workspace] 
  count = local.instance_count_map[terraform.workspace]
  lifecycle {
    create_before_destroy = true
  } 
}


#resource "aws_instance" "netolo_node2" {
#  for_each = local.instance_common_maps[terraform.workspace]
#  ami = data.aws_ami.ubuntu_latest.id
#  instance_type = each.value
#  name = each.key
#}



