#App Tier

#Create Subnet
resource "aws_subnet" "app_subnet_ash-dpl" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.16.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.name}-subnet"
  }
}

# Create NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = var.vpc_id
  subnet_ids = [aws_subnet.app_subnet_ash-dpl.id]

  tags = {
      Name = "${var.name}-public-nacl"
  }

  egress {
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3000
    to_port    = 3000
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "10.0.19.0/24"
    from_port  = 27017
    to_port    = 27017
  }
}

#Create Route Table
resource "aws_route_table" "public-dpl" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "10.0.1.0/0"
        gateway_id = var.gateway_id_var
    }

    tags = {
        Name = "${var.name}-rtb"
    }
}

#Route Table Association
resource "aws_route_table_association" "assoc" {
    subnet_id = aws_subnet.app_subnet_ash-dpl.id
    route_table_id = aws_route_table.public-dpl.id
}

#Template File
data "template_file" "app_init"{
    template = file("./scripts/app/init.sh.tpl")
    vars = {
      my_name = "${var.name} is my name"
      db_priv_ip = "${var.db_ip}"
    }
}


# Launch an instance
resource "aws_instance" "app_instance_ash-dpl" {
  ami = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.app_subnet_ash-dpl.id
  vpc_security_group_ids = [aws_security_group.aws_ash_security_group-dpl.id]
    
  user_data = data.template_file.app_init.rendered

  tags = {
    Name = "${var.name}-inst"
  }
    key_name = "ash-Eng54-"
}


# Security groups
resource "aws_security_group" "aws_ash_security_group-dpl" {
  name          = "${var.name}-sg"
  vpc_id        = var.vpc_id
  description   = "security group from my IP"

  ingress {
    description = "Allows access on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows access on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows access on port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows access on my IP port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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