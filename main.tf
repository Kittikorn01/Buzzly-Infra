# 1. AMI Data Source (Ubuntu 22.04 LTS)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 2. Security Group (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "buzzly-web-sg"
  description = "Allow SSH, HTTP (80), and API (3001)"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # เปิด SSH ให้เข้าได้จากทุกที่
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # เปิด Port 80 สำหรับหน้าเว็บ
  }

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # เปิด Port 3001 สำหรับ Mock API
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # เปิดให้ Ping ได้เพื่อทดสอบ 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. EC2 Instance
resource "aws_instance" "buzzly_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # สั่งให้รันสคริปต์ติดตั้งตอนเปิดเครื่อง
  user_data = templatefile("${path.module}/scripts/setup.tftpl", {
    github_repo_url           = var.github_repo_url
    supabase_url              = var.supabase_url
    supabase_anon_key         = var.supabase_anon_key
    supabase_service_role_key = var.supabase_service_role_key
  })

  tags = {
    Name = "Buzzly-Staging-Server"
  }

  # มั่นใจว่า EBS Volume มีขนาดพอสำหรับ Docker
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}
