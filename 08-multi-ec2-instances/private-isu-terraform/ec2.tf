#private_isu instance
resource "aws_instance" "private_isu_web" {
  ami                         = "ami-04f51de327e6c4656" #Private-isu-AMI
  instance_type               = "c7a.large"
  iam_instance_profile        = aws_iam_instance_profile.private_isu_web_profile.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.private_isu_web.id]
  subnet_id                   = aws_subnet.public_1a.id
  user_data                   = <<-EOF
        snap install amazon-ssm-agent --classic
        snap start amazon-ssm-agent

    EOF
  tags = {
    Name = "Private-isu"
  }
}

resource "aws_instance" "private_isu_web02" {
  ami                         = "ami-04f51de327e6c4656" #Private-isu-AMI
  instance_type               = "c7a.large"
  iam_instance_profile        = aws_iam_instance_profile.private_isu_web_profile.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.private_isu_web.id]
  subnet_id                   = aws_subnet.public_1a.id
  user_data                   = <<-EOF
        snap install amazon-ssm-agent --classic
        snap start amazon-ssm-agent

    EOF
  tags = {
    Name = "Private-isu02"
  }
}

#benchmark instance
resource "aws_instance" "benchmark" {
  ami                         = "ami-04f51de327e6c4656" #Private-isu-AMI
  instance_type               = "c7a.xlarge"
  iam_instance_profile        = aws_iam_instance_profile.private_isu_web_profile.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.benchmark.id]
  subnet_id                   = aws_subnet.public_1a.id
  user_data                   = <<-EOF
        snap install amazon-ssm-agent --classic
        snap start amazon-ssm-agent

    EOF
  tags = {
    Name = "Private-isu-benchmark"
  }
}
