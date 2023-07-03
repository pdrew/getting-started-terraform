# aws_elb_service_account
data "aws_elb_service_account" "nginx" {

}

# aws_lb
resource "aws_lb" "nginx" {
  name               = "${local.naming_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.nginx.id
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags

  depends_on = [aws_s3_bucket_policy.nginx]
}

# aws_lb_target_group
resource "aws_lb_target_group" "nginx" {
  name     = "${local.naming_prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id
  tags     = local.common_tags
}

# aws_lb_listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-alb-listener" })
}

# aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "web_server_attachments" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.web_servers[count.index].id
  port             = 80
}