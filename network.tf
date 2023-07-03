data "aws_availability_zones" "available" {
  state = "available"
}

module "app" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "5.0.0"
  cidr                    = var.vpc_cidr_block
  azs                     = slice(data.aws_availability_zones.available.names, 0, var.vpc_public_subnet_count)
  public_subnets          = [for subnet in range(var.vpc_public_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]
  enable_dns_hostnames    = var.vpc_enable_dns_hostnames
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch
  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  tags                    = merge(local.common_tags, { Name = "${local.naming_prefix}-vpc" })
}

resource "aws_security_group" "nginx_sg" {
  name   = "${local.naming_prefix}-${var.web_server_sg_name}"
  vpc_id = module.app.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "alb_sg" {
  name   = "${local.naming_prefix}-${var.alb_sg_name}"
  vpc_id = module.app.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}