# Create an IAM role that EC2 can assume and attach the policy and profile to add SSM permissionss
resource "aws_iam_role" "ec2_ssm" {
  name = "ec2-ssm-role-pandas"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "ec2-ssm-instance-profile-pandas"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_instance" "ec2_pandas" {
  ami                         = data.aws_ami.ec2_pandas.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ec2_pandas.name]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  user_data                   = var.user_data
  user_data_replace_on_change = true

  tags = {
    Name = "ec2_pandas"
  }
}

# Provision an Amazon Linux 2 AMI
data "aws_ami" "ec2_pandas" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

}

# Create security group for the instance and egress rule
resource "aws_security_group" "ec2_pandas" {
  name        = "allow_tls-pandas"
  description = "Allow TLS inbound traffic and all outbound traffic"
}

resource "aws_vpc_security_group_egress_rule" "ec2_pandas" {
  security_group_id = aws_security_group.ec2_pandas.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
