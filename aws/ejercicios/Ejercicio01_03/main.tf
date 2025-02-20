
resource "aws_key_pair" "deployer-key" {
  key_name      = "${var.project_name}-deployer-key"
  public_key    = file(var.clave_ssh_pub)
}

resource "aws_ebs_volume" "web" {
  availability_zone = var.availability_zone
  size              = 4
  type = "gp3"
  encrypted = true
  tags = {
    Name = "${var.project_name}-web-ebs"
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh_${var.project_name}"
  description = "Allow SSH Inbound Traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from VPC ${var.project_name}"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_http-${var.project_name}"
  description = "Allow http inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "http from VPC"
    from_port = 80
    to_port = 80
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "web" {
  ami = "ami-04a92520784b93e73"
  availability_zone = var.availability_zone
  instance_type = var.instance_type
  vpc_security_group_ids = [
  aws_security_group.allow_ssh.id,
  aws_security_group.allow_http.id
  ]

  user_data = templatefile(
    "${path.module}/userdata.sh",
    {}
  )
  key_name = aws_key_pair.deployer-key.key_name
  tags = {
    Name = "${var.project_name}-web-instance"
  }
}

resource "aws_eip" "eip" {
  instance      = aws_instance.web.id
  # corrección de deprecated
  domain = "vpc"
  # vpc           = true
  tags          = {
    Name        = "${var.project_name}-web-epi"
  }
}
resource "aws_volume_attachment" "web" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.web.id
  instance_id = aws_instance.web.id
}