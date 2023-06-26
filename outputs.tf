output "instance_publi_dns" {
  description = "Public DNS of the EC2 instance"
  value       = "http://${aws_instance.nginx1.public_dns}"
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.nginx1.public_ip
}