resource "aws_instance" "ec2_task3" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
  ami                         = data.aws_ami.ec2_task3.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ec2_task3.key_name
  security_groups             = [aws_security_group.ec2_task3.name]
  user_data                   = var.user_data
  user_data_replace_on_change = true
}


data "aws_ami" "ec2_task3" {
  most_recent = true

  owners = ["amazon"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  ## homework:start
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  ## homework:end

}

resource "aws_key_pair" "ec2_task3" {
  key_name   = "my-ec2-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "ec2_task3" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_task3" {
  security_group_id = aws_security_group.ec2_task3.id
  cidr_ipv4         = "0.0.0.0/0" # use more restrictions in a production setting
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "ec2_task3" {
  security_group_id = aws_security_group.ec2_task3.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
