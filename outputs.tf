output "alb_public_dns" {
  description = "Public DNS of the application load balancer"
  value       = "http://${aws_lb.nginx.dns_name}"
}