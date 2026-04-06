# variables.tf
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "my_home_ip" {
  description = "YOUR HOME/WORK IP"
  type = string
  sensitive = true
}

variable "aws-key" {
  description = "YOUR AWS KEYPAIR"
  type = string
  sensitive = true
}

# main.tf
locals {
  common_tags = {
    Environment = "homelab"
    ManagedBy   = "terraform"
    Purpose     = "cybersecurity-training"
  }
}

# Create VPC
resource "aws_vpc" "homelab_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab VPC"
  })
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.homelab_vpc.id
  cidr_block = var.public_subnet_cidr

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab Public Subnet"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.homelab_vpc.id

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab IGW"
  })
}

# Create Route Table
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.homelab_vpc.id
}

# Create Route to IGW in Route Table
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Route Table to Public Subnet
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route-table.id
}

# Create Security Group for Windows 10 and Kali Linux Instances
resource "aws_security_group" "win-kali-security-group" {
  name_prefix = "win-kali-"
  description = "Security group allowing SSH, RDP, and ICMP from home/work IP only"
  vpc_id = aws_vpc.homelab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.my_home_ip]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab Windows / Kali Security Group"
  })
}

# Create Security Group for Linux Security Tools Instance
resource "aws_security_group" "linux-security-tools" {
  name_prefix = "security-tools-"
  description = "Ingress and egress rules for Security Tools Box"
  vpc_id = aws_vpc.homelab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = 5900
    to_port     = 5920
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "udp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip]  
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab Linux Security Tools Security Group"
  })
}

# Create Windows Instance
resource "aws_instance" "windows" {
  ami = "ami-060b1c20c93e475fd"
  instance_type = "t3.medium"  # t2.micro makes Windows lag
  subnet_id = aws_subnet.public_subnet.id

  key_name = var.aws-key
  security_groups = [aws_security_group.win-kali-security-group.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab [Windows]"
  })
}

# Create Kali Attacker Instance
resource "aws_instance" "kali" {
  ami = "ami-0b02670313196539c"
  instance_type = "t3.small"  # Could also use t.2micro
  subnet_id = aws_subnet.public_subnet.id

  key_name = var.aws-key
  security_groups = [aws_security_group.win-kali-security-group.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab [Kali]"
  })
}

# Create Security Tools Instance
resource "aws_instance" "security-tools" {
  ami = "ami-0901bbd9d6e996fb7"
  instance_type = "t3.large"
  subnet_id = aws_subnet.public_subnet.id

  key_name = var.aws-key
  security_groups = [aws_security_group.linux-security-tools.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, {
    Name = "Cybersecurity Homelab [Security Tools]"
  })
}

# Auto-shutdown tags to save costs
resource "aws_ec2_tag" "shutdown_windows" {
  resource_id = aws_instance.windows.id
  key         = "shutdown-schedule"
  value       = "cron(0 20 * * ? *)"  # Shuts down at 8 PM daily
}

resource "aws_ec2_tag" "shutdown_kali" {
  resource_id = aws_instance.kali.id
  key         = "shutdown-schedule"
  value       = "cron(0 20 * * ? *)"
}

resource "aws_ec2_tag" "shutdown_tools" {
  resource_id = aws_instance.security-tools.id
  key         = "shutdown-schedule"
  value       = "cron(0 20 * * ? *)"
}

# outputs.tf
output "instance_public_ip_win" {
  value = "Windows Box IP Address: ${aws_instance.windows.public_ip}"
}

output "instance_public_ip_kali" {
  value = "Kali Box IP Address: ${aws_instance.kali.public_ip}"
}

output "instance_public_ip_security-tools" {
  value = "Security Tools Box IP Address: ${aws_instance.security-tools.public_ip}"
}

output "connection_info" {
  value = <<-EOT
    
    IMPORTANT SECURITY NOTES:
    =========================
    All security groups are restricted to your home IP only: ${var.my_home_ip}
    If your IP changes, update var.my_home_ip and run 'terraform apply'
    
    CONNECTION INFO:
    ================
    Windows: rdp://${aws_instance.windows.public_ip}
    Kali: ssh -i ${var.aws-key}.pem kali@${aws_instance.kali.public_ip}
    Security Tools: ssh -i ${var.aws-key}.pem ubuntu@${aws_instance.security-tools.public_ip}
    
    COST SAVING:
    ============
    Instances automatically tag for shutdown at 8 PM daily
    Use AWS Instance Scheduler or manual stop/start to save costs
    Run 'terraform destroy' when you're done hacking ethically
    
  EOT
}