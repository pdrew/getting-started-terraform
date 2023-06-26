variable "aws_profile" {
  type        = string
  description = ""
  default     = "tf"
}

variable "aws_region" {
  type        = string
  description = ""
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = ""
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = ""
  default     = true
}

variable "public_subnet_cidr_block" {
  type        = string
  description = ""
  default     = "10.0.0.0/24"
}

variable "public_subnet_map_public_ip_on_launch" {
  type        = bool
  description = ""
  default     = true
}

variable "route_table_cidr_block" {
  type        = string
  description = ""
  default     = "0.0.0.0/0"
}

variable "security_group_name" {
  type        = string
  description = ""
  default     = "nginx_sg"
}

variable "nginx_instance_type" {
  type        = string
  description = ""
  default     = "t2.micro"
}

variable "my_ip" {
  type        = string
  description = ""
  default     = "110.145.35.230/32"
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "Globomantics"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
}