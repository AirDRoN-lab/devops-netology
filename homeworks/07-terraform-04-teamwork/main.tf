provider "aws" {
#  profile = "terraform"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "netos3"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
#    dynamodb_table = "terraform-lock"
  }
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

module "ec2_instance" {
source  = "terraform-aws-modules/ec2-instance/aws"
version = "~> 3.0"

name = "single-instance"

ami                    = data.aws_ami.ubuntu_latest.id
instance_type          = "t2.micro"
monitoring             = true

tags = {
  Terraform   = "true"
  Environment = "dev"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "stagevpc"
  cidr = "10.0.0.0/16"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
