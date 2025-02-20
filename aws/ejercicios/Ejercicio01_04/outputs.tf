output "instance_public_ips" {
  description = "Las IPs públicas de las instancias web"
  value       = aws_instance.web[*].public_ip
}

output "ssh_commands" {
  description = "Comandos SSH para las instancias web"
  value = [
    for ip in aws_instance.web[*].public_ip : "ssh -l ubuntu ${ip}"
  ]
}
