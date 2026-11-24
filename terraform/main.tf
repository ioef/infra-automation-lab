terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

variable "allowed_cidrs" {
  description = "IPv4 CIDRs allowed to access SSH and the Sentry web interface."
  type        = list(string)
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/resolute/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_key_pair" "sentry_key" {
  key_name   = "sentry-key"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

resource "aws_security_group" "sentry_sg" {
  name = "sentry-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sentry_vm" {
  ami = data.aws_ssm_parameter.ubuntu_ami.value
  # The instance type defines both specs: 4 vCPU and 16 GiB RAM.
  instance_type          = "m6i.xlarge"
  key_name               = aws_key_pair.sentry_key.key_name
  vpc_security_group_ids = [aws_security_group.sentry_sg.id]

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "sentry-vm"
  }
}

output "public_ip" {
  value = aws_instance.sentry_vm.public_ip
}