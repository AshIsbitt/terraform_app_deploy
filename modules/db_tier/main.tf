#Create Subnet
resource "aws_subnet" "db_subnet_ash" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.16.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.name}-subnet"
  }
}

# Create NACL
resource "aws_network_acl" "private_nacl" {
  vpc_id = var.vpc_id
  subnet_ids = []

  tags = {
      Name = "${var.name}-public-nacl"
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = aws_subnet.app_subnet_ash-dpl.id
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 210
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_subnet.app_subnet_ash-dpl.id
    from_port  = 27017
    to_port    = 27017
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "5.66.196.52/32"
    from_port  = 22
    to_port    = 22
  }

    ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
}

# Security groups
resource "aws_security_group" "aws_ash_security_group_private" {
  name          = "${var.name}-sg"
  vpc_id        = var.vpc_id
  description   = "security group "

  ingress {
    description = "Allows port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allows port 80"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows port 80"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["89.36.66.9/32"]
  }
  # default outbound rules for SG is it let everything out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags          = {
    Name        = "${var.name}-tags"
  }
  
}