terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Set to Mumbai to match your AWS CLI
}

# Create a Security Group to allow incoming web traffic
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Deploy a single Free Tier EC2 instance
resource "aws_instance" "web_server" {
  ami                    = "ami-007020fd9c84e18c7" # Ubuntu 24.04 LTS Free Tier AMI in ap-south-1
  instance_type          = "t3.micro"             # Strictly Free Tier
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # User data script to host your index.html file on boot
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              echo "<h1>Hello World! Live from AWS Free Tier via IaC.</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "DevOps-FreeTier-Demo"
  }
}

# Output the public IP address so you can access it
output "public_ip" {
  value = aws_instance.web_server.public_ip
}

