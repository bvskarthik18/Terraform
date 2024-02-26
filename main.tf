#Creates VPC using vpc-module

module "aws_vpc" {
  source = "./vpc-module"

}

#creates 3 subnets using subnet-module
module "aws_subnet" {
  source = "./subnet-module"
  vpc_id = module.aws_vpc.my_vpc_id
  subnets = {
    subnet-1 = {
      cidr_block        = "10.0.1.0/24"
      az = "ca-central-1a"
    }
    subnet-2 = {
      cidr_block        = "10.0.2.0/24"
      az = "ca-central-1b"
    }
    subnet-3 = {
      cidr_block        = "10.0.3.0/24"
      az = "ca-central-1d"
    }
  }
}