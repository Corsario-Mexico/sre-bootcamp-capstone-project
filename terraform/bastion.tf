# Bastion instance

resource "aws_security_group" "David_Sol_bastion_security_group" {
  name        = "David_Sol_bastion_security_group"
  description = "Bastion Security Group"
  vpc_id      = aws_vpc.David_Sol_vpc.id
  ingress {
    description = "SSH from My IP"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${chomp(data.http.my_ip_address.body)}/32"]
  }
  egress {
    description = "Allow All"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "David_Sol_bastion_security_group"
  }
}

resource "aws_instance" "David_Sol_bastion" {
  ami                         = var.instance_ami
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.David_Sol_public_subnets[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.David_Sol_bastion_security_group.id]
  key_name                    = var.instance_key
  user_data                   = filebase64("${path.module}/setup_bastion.sh")
  tags = {
    Name = "David_Sol_bastion"
  }
}
