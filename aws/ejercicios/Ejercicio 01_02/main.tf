provider "aws" {
  region = "eu-west-3" #aqui declaramos el proveedor y la región que vamos a utilizar (aws y paris)
}

#data "aws_ami" "ubuntu" { # con el data podemos buscar un recurso, en este caso una ami de ubuntu
 # most_recent = true

# filter { #diferentes filtros para buscar la ami que queremos
#    name = "name"
#    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
#  }

#  filter {
#    name = "root-device-type"
#    values = ["ebs"]
#  }

# filter {
#    name = "virtualization-type"
#   values = ["hvm"]
#  }

#  owners = ["099720109477"]
#}

variable "clave_ssh_pub" {  # en estas variables ponemos los nombre que utilizamos en el tfvars, donde declaramos que es cada variable.
  type = string
}
variable "clave_ssh" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "project_name" {
  type = string
}

resource "aws_key_pair" "deployer" {  # con "resource" desplegamos el recurso de par de claves (aws_key_pair)
  key_name = "deployer-key-ubuntu-${var.project_name}"
  public_key = file(var.clave_ssh_pub)
}

resource "aws_security_group" "allow_ssh" { # desplegamos el recurso del security group en la VPC declarada en vars
  name = "allow_ssh-${var.project_name}"
  description = "allow ssh"
  vpc_id = var.vpc_id

  ingress {
    description = "ssh from vpc"
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
    Name = "allow_ssh"
  }
}

resource "aws_instance" "web" {
  ami = "ami-04a92520784b93e73"
  instance_type = "t3.micro"
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id
  ]
  tags = {
    Name = "HelloWorld-${var.project_name}"
  }

  provisioner "local-exec" {
    command = "echo el SSH id es ${self.id}"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file(var.clave_ssh)
  }

  provisioner "remote-exec" {
    inline = [
    "echo hola esto ha funcionado >> fichero.txt"
    ]
  }
}

output "ip_instance" {
  value = aws_instance.web.public_ip
}

output "ssh" {
  value = "ssh -l ubuntu ${aws_instance.web.public_ip}"
}

