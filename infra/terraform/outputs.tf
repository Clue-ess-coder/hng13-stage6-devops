output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.microservices.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.microservices.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.microservices.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.microservices.id
}

output "ssh_connection_string" {
  description = "SSH connection string"
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_eip.microservices.public_ip}"
}

output "application_url" {
  description = "Application URL"
  value       = "https://${var.domain_name}"
}

output "ansible_inventory_path" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}
