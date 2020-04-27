#App Tier

#Create Subnet
resource "aws_subnet" "app_subnet_ash-dpl" {
  vpc_id = var.vpc_id
  cidr_block = "172.31.132.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.name}-subnet"
  }
}

# Create NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = var.vpc_id
  subnet_ids = []

  tags = {
      Name = "${var.name}-public-nacl"
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
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
    cidr_block = "5.66.196.52/32"
    from_port  = 22
    to_port    = 22
  }

}

#Create Route Table
resource "aws_route_table" "public-dpl" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.gateway_id_var
    }

    tags = {
        Name = "${var.name}-rtb"
    }
}

#Route Table Association
resource "aws_route_table_association" "assoc-dpl" {
    subnet_id = aws_subnet.app_subnet_ash-dpl.id
    route_table_id = var.gateway_id_var
}

#Template File
data "template_file" "app_init"{
    template = file("./scripts/app/init.sh.tpl")
    vars = {
      my_name = "${var.name} is my name"
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
  description   = "security group that allows port 80 from anywhere"

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