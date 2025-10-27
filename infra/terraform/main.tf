resource "aws_key_pair" "my_key_pair" {
  key_name   = "mykey_esm"
  public_key = file("my-keypair.pub")

}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "aws_sg" {
  vpc_id = aws_default_vpc.default.id
  tags = {
    Name = "mysg_esm"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.aws_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "allowshh" {
  security_group_id = aws_security_group.aws_sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_jenkins" {
  security_group_id = aws_security_group.aws_sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
}
resource "aws_vpc_security_group_ingress_rule" "allow_backend" {
  security_group_id = aws_security_group.aws_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 4000
  to_port           = 4000
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "allow_promethesus" {
  security_group_id = aws_security_group.aws_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9000
  to_port           = 9000
  ip_protocol       = "tcp"
}

resource "aws_instance" "myinstance_esm" {

  security_groups = [aws_security_group.aws_sg.name]
  key_name        = aws_key_pair.my_key_pair.key_name
  instance_type   = var.instance_type
  ami             = var.instance_ami

  tags = {
    Name        = "esm_${var.environment}_server"
    Environment = var.environment
  }

  root_block_device {
    volume_size = var.instance_storage_size
    volume_type = var.instance_storage_type
  }
}

resource "aws_eip" "esm_ip" {
  instance = aws_instance.myinstance_esm.id
}


resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventories/${var.environment}/hosts"
  content  = <<EOF
[${var.environment}]
${aws_eip.esm_ip.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/my-keypair
EOF
}
