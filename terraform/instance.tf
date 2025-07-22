data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "docker_host" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_server_sg_tf.id]
  key_name                    = aws_key_pair.ec2_key.key_name
  user_data = <<-EOT
#!/bin/bash
sudo yum update -y
sudo yum -y install docker
sudo systemctl start docker   # Corrected command: 'systemctl start docker'
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
# WARNING: The following line is a major security risk and is not recommended.
# sudo chmod 666 /var/run/docker.sock
EOT

  tags = {
    Name = "Docker-Host"
  }
}


resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "my-generated-ec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.docker_host.public_ip
}

