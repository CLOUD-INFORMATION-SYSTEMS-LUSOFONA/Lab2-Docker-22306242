provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "network" {
  source = "./modules/vpc"

  vpc_name            = "week9-vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone_1 = "us-east-1a"
  availability_zone_2 = "us-east-1b"
}

module "compute" {
  source = "./modules/ec2"

  instance_name = "week9-instance"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_id
  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
}

module "vpc_public" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "week9-public-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.10.0/24", "10.1.20.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Project = "CloudComputing"
  }
}

variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]
}

resource "aws_security_group" "dynamic_web" {
  name   = "week9-dynamic-web"
  vpc_id = module.network.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "week9-dynamic-web"
  }
}