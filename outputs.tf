output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.buzzly_server.public_ip
}

output "web_url" {
  description = "Website URL"
  value       = "http://${aws_instance.buzzly_server.public_ip}"
}

output "api_url" {
  description = "API Endpoint"
  value       = "http://${aws_instance.buzzly_server.public_ip}:3001"
}

output "ssh_command" {
  description = "Command to Connect via SSH"
  value       = "ssh -i YOUR_KEY.pem ubuntu@${aws_instance.buzzly_server.public_ip}"
}
