resource "aws_vpc" "vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "private-isu-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "us-east-1a"
  cidr_block        = "10.10.0.0/24"
}

resource "aws_subnet" "public_1c" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "us-east-1c"
  cidr_block        = "10.10.3.0/24"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_1a_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_1a_rtb.id
}

resource "aws_route_table" "public_1c_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public_1c_rtb.id
}

# vpc.tf に追記

resource "aws_db_subnet_group" "private_isu_aurora" {
  name       = "private-isu-mysql-subnet-group"
  subnet_ids = [aws_subnet.mysql-a.id, aws_subnet.mysql-c.id, aws_subnet.mysql-d.id]

  tags = {
    Name = "private-isu aurora subnet group"
  }
}

resource "aws_subnet" "mysql-a" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "us-east-1a"
  cidr_block        = "10.10.9.0/24"
}

resource "aws_subnet" "mysql-c" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "us-east-1c"
  cidr_block        = "10.10.11.0/24"
}

resource "aws_subnet" "mysql-d" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "us-east-1d"
  cidr_block        = "10.10.12.0/24"
}

# memcached用サブネット
resource "aws_subnet" "cache_subnet" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "us-east-1c"
  cidr_block        = "10.10.5.0/24"
}
