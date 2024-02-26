resource "aws_subnet" "my_subnets"{
    for_each = var.subnets
    tags = {
    Name = "${each.key}"
  }
    vpc_id = var.vpc_id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az
}

#creates Internet Gateway using

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "igw"
  }
}

#Creates Public Route Table

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

# creates Route Table Association

resource "aws_route_table_association" "rta" {
    subnet_id = aws_subnet.my_subnets[keys(aws_subnet.my_subnets)[0]].id
    route_table_id = aws_route_table.public_rt.id
  
}