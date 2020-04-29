#Create Subnet
resource "aws_subnet" "db_subnet_ash" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.19.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.name}-subnet-private"
  }
}

# Create NACL
resource "aws_network_acl" "private_nacl" {
  vpc_id = var.vpc_id
  subnet_ids = [aws_subnet.db_subnet_ash.id]

  tags = {
      Name = "${var.name}-private-nacl"
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "10.0.16.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "10.0.16.0/24"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "10.0.16.0/24"
    from_port  = 27017
    to_port    = 27017
  }
}

# Security groups
resource "aws_security_group" "aws_ash_security_group_private" {
  name          = "${var.name}-sg"
  vpc_id        = var.vpc_id
  description   = "security group"

  ingress {
    description = "Allows access on my IP port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/24"]
      }

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags          = {
    Name        = "${var.name}-tags"
  }
} 

resource "aws_route_table" "private_route" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-private-rtb"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id = aws_subnet.db_subnet_ash.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_instance" "mongod" {
  ami   = var.ami_id_private
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.db_subnet_ash.id
  vpc_security_group_ids = [aws_security_group.aws_ash_security_group_private.id]
  key_name = "ash-Eng54-"

  tags = {
    Name = "${var.name}-inst-private"
  }
}

output "instance_ip_addr" {
  value = aws_instance.mongod.private_ip
}