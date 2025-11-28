# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use existing SSH Key Pair (already created in AWS)
# If key doesn't exist, you need to create it manually in AWS Console

# Security Group
resource "aws_security_group" "microservices" {
  name        = "${var.project_name}-sg"
  description = "Security group for microservices application"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
    description = "SSH access"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Traefik Dashboard (optional, should be restricted in production)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
    description = "Traefik Dashboard"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Instance
resource "aws_instance" "microservices" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.microservices.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              apt-get update
              apt-get upgrade -y
              
              # Set hostname
              hostnamectl set-hostname ${var.project_name}
              
              # Create application directory
              mkdir -p /opt/app
              
              # Install basic utilities
              apt-get install -y curl wget git unzip
              
              # Configure timezone
              timedatectl set-timezone UTC+1
              EOF

  tags = {
    Name = "${var.project_name}-server"
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

# Elastic IP
resource "aws_eip" "microservices" {
  instance = aws_instance.microservices.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    server_ip    = aws_eip.microservices.public_ip
    ssh_user     = "ubuntu"
    ssh_key_path = "~/.ssh/id_ed25519"
    domain_name  = var.domain_name
    acme_email   = var.acme_email
    git_repo_url = var.git_repo_url
    git_branch   = var.git_branch
    jwt_secret   = var.jwt_secret
  })

  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"

  depends_on = [aws_eip.microservices]
}

# Trigger Ansible after Terraform apply
resource "null_resource" "run_ansible" {
  triggers = {
    instance_id = aws_instance.microservices.id
    always_run  = timestamp()
  }

  provisioner "local-exec" {
    command     = "sleep 60 && ansible-playbook -i ${path.module}/../ansible/inventory.ini ${path.module}/../ansible/playbook.yml"
    working_dir = path.module
    on_failure  = continue
  }

  depends_on = [
    local_file.ansible_inventory,
    aws_eip.microservices
  ]
}
