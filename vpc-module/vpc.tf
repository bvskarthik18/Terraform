resource "aws_vpc" "my_vpc" {
  cidr_block       = var.cidr

  tags = {
    Name = var.vpc_name
  }
}

output "my_vpc_id" {
  value = aws_vpc.my_vpc.id
}
