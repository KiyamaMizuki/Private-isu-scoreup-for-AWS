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

# iam.tf に追記

data "aws_iam_policy" "enhanced_monitoring" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role" "private_isu_rds_monitoring_role" {
    name = "private-isu-rds-monitoring-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "rds.amazonaws.com"
            }
        },
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "monitoring.rds.amazonaws.com"
            }
        },
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        },
        ]
    })

    tags = {
        Name = "private-isu RDS Monitoring Role"
    }
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring_attachment" {
    role       = aws_iam_role.private_isu_rds_monitoring_role.name
    policy_arn = data.aws_iam_policy.enhanced_monitoring.arn
}