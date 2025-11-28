variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hng13-stage6"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c7i-flex.large"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04 LTS)"
  type        = string
  default     = ""  # Will be fetched automatically if not provided
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "acme_email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
}

variable "git_repo_url" {
  description = "Git repository URL for the application"
  type        = string
}

variable "git_branch" {
  description = "Git branch to deploy"
  type        = string
  default     = "main"
}

variable "jwt_secret" {
  description = "JWT secret for application"
  type        = string
  sensitive   = true
  default     = "myfancysecret"
}
