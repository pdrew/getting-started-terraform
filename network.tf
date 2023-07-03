data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags                 = merge(local.common_tags, { Name = "${local.naming_prefix}-vpc" })
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = local.common_tags
}

resource "aws_subnet" "public_subnets" {
  count                   = var.vpc_public_subnet_count
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = merge(local.common_tags, { Name = "${local.naming_prefix}-public-subnet${count.index + 1}" })
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.app.id
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-route-table" })
}

resource "aws_route_table_association" "app_public_subnets" {
  count          = var.vpc_public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.app.id
}

resource "aws_security_group" "nginx_sg" {
  name   = "${local.naming_prefix}-${var.web_server_sg_name}"
  vpc_id = aws_vpc.app.id

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
  vpc_id = aws_vpc.app.id

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