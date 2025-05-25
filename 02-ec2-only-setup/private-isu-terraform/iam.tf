resource "aws_iam_role" "private_isu_web" {
  name               = "private_isu_web"
  assume_role_policy = data.aws_iam_policy_document.private_isu_web_assume_role.json
}
data "aws_iam_policy_document" "private_isu_web_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "private_isu_web_ssm_managed_instance_core" {
  role       = aws_iam_role.private_isu_web.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
}

# privte-isuインスタンスプロファイルを作成
resource "aws_iam_instance_profile" "private_isu_web_profile" {
  name = "private-isu-web-instance-profile"
  role = aws_iam_role.private_isu_web.name
}