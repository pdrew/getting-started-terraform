data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "web_servers" {
  count                  = var.instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[(count.index % var.vpc_public_subnet_count)].id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name

  user_data = templatefile("${path.module}/templates/startup_script.tpl", {
    s3_bucket_name = aws_s3_bucket.nginx.id
  })
  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-instance${count.index + 1}" })

  depends_on = [aws_iam_role_policy.allow_s3_all]
}

# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name               = "${local.naming_prefix}-allow-nginx-s3"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = local.common_tags
}

# aws_iam_policy
resource "aws_iam_role_policy" "allow_s3_all" {
  name = "${local.naming_prefix}-allow-s3-all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
    }
  ]
}
EOF

}


# aws_iam_instance_profile
resource "aws_iam_instance_profile" "nginx_profile" {
  name = "${local.naming_prefix}-nginx-profile"
  role = aws_iam_role.allow_nginx_s3.name
  tags = local.common_tags
}