provider "aws" {
	region = "eu-west-1"
}

# Create VPC
# resource "aws_vpc" "app_vpc_ash" {
# 	cidr_block = "10.0.0.0/16"

# 	tags = {
# 		Name = "Ash_App_VPC"
# 	}
# }

# Use Devops VPC
# Create new subnet
# Set instance in subnet

resource "aws_subnet" "app_subnet_ash-dpl" {
  vpc_id = var.vpc_id
  cidr_block = "172.31.149.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.name}-subnet"
  }
}

#route table
resource "aws_route_table" "public-dpl" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = data.aws_internet_gateway.default-igw-dpl.id
    }

    tags = {
        Name = "${var.name}-rtb"
    }
}

#rtb associations
resource "aws_route_table_association" "assoc-dpl" {
    subnet_id = aws_subnet.app_subnet_ash-dpl.id
    route_table_id = aws_route_table.public-dpl.id
}


# querying existing infrastructure to pull the IGW data
data "aws_internet_gateway" "default-igw-dpl" {
    filter {
        name = "attachment.vpc-id"
        values = [var.vpc_id]
    }
}

data "template_file" "app_init"{
    template = file("./scripts/app/init.sh.tpl")
}


# Launch an instance
resource "aws_instance" "app_instance_ash-dpl" {
	#James' AMI ID
	ami = var.ami_id
	instance_type = "t2.micro"
	associate_public_ip_address = true
    subnet_id = aws_subnet.app_subnet_ash-dpl.id
    vpc_security_group_ids = [aws_security_group.aws_ash_security_group-dpl.id]
    
    user_data = data.template_file.app_init.rendered

    #https://github.com/hovell722/first-terraform/blob/master/main.tf
    # connection {
    #     type     = "ssh"
    #     user     = "ubuntu"
    #     host = self.public_ip
    #     private_key = "${file("~/.ssh/ash-Eng54-.pem")}"
    # }

    # provisioner "remote-exec" {
    #     inline = ["mkdir /home/ubuntu/app"]
    # }

    # #https://www.terraform.io/docs/provisioners/file.html
    # provisioner "file" {
    #     source      = "/Users/AshIsbitt/Desktop/NodePacker/app/"
    #     destination = "/home/ubuntu/app"
    # }

    # provisioner "remote-exec" {
    #     inline = ["cd /home/ubuntu/app/",
    #             "echo CD CD CD", 
    #             "sudo npm install",
    #             "echo INSTALL COMPLETE INSTALL COMPLETE INSTALL COMPLETE",
    #             "sudo npm start &",
    #             "PID=&!",
    #             "sleep 2s",
    #             "kill =INT &PID"]
    # }

	tags = {
		Name = "${var.name}-inst"
	}
    key_name = "ash-Eng54-"
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "aws_ash_security_group-dpl" {
    name = "app-sg-ash-dpl"
    vpc_id = var.vpc_id
    description = "Allows all entry on port 80"

    ingress {
        description = "port 80 entry"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "port 22 entry"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["5.66.196.52/32"]
    }

        ingress {
        description = "port 8080 entry"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["5.66.196.52/32"]
    }

        ingress {
        description = "port 3000 entry"
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["5.66.196.52/32"]
    }

        ingress {
        description = "port 443 entry"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.name}-sec-group"
    }
}

