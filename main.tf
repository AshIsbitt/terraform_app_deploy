provider "aws" {
	region = "eu-west-1"
}

#Create VPC
resource "aws_vpc" "app_vpc_ash" {
	cidr_block = "10.0.0.0/16"

	tags = {
		Name = "${var.name}-VPC"
	}
}

# querying existing infrastructure to pull the IGW data
# data "aws_internet_gateway" "default-igw-dpl" {
#     filter {
#         name = "attachment.vpc-id"
#         values = [var.vpc_id]
#     }
# }

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.app_vpc_ash.id

    tags = {
        name = "${var.name}-IGW"
    }
}

module "app" {
    source = "./modules/app_tier"
    vpc_id = aws_vpc.app_vpc_ash.id
    name = var.name
    ami_id = var.ami_id
    gateway_id_var = aws_internet_gateway.igw.id
}

