resource "aws_rds_cluster" "private_isu_db" {
  availability_zones                    = ["us-east-1a", "us-east-1c", "us-east-1d"]
  cluster_identifier                    = "private-isu-db"
  database_insights_mode                = "advanced"
  database_name                         = "isuconp"
  db_cluster_parameter_group_name       = "default.aurora-mysql8.0"
  db_subnet_group_name                  = aws_db_subnet_group.private_isu_aurora.name
  delete_automated_backups              = false
  deletion_protection                   = false
  enabled_cloudwatch_logs_exports       = ["slowquery"]
  engine                                = "aurora-mysql"
  engine_lifecycle_support              = "open-source-rds-extended-support-disabled"
  engine_mode                           = "provisioned"
  engine_version                        = "8.0.mysql_aurora.3.05.2"
  master_password                       = "password" # NOTE: 本来はパスワードを別で管理する
  master_username                       = "isuconp"
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.private_isu_rds_monitoring_role.arn
  network_type                          = "IPV4"
  performance_insights_enabled          = true
  performance_insights_retention_period = 465
  port                                  = 3306
  storage_type                          = "aurora-iopt1"
  skip_final_snapshot                   = true
  vpc_security_group_ids                = [aws_security_group.private_isu_aurora.id]
}

resource "aws_rds_cluster_instance" "private_isu_db_instance" {
  cluster_identifier                    = "private-isu-db"
  db_parameter_group_name               = "default.aurora-mysql8.0"
  db_subnet_group_name                  = aws_db_subnet_group.private_isu_aurora.name
  engine                                = "aurora-mysql"
  engine_version                        = "8.0.mysql_aurora.3.05.2"
  identifier                            = "private-isu-aurora-instance"
  instance_class                        = "db.r5.large"
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.private_isu_rds_monitoring_role.arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 465
  tags = {
    devops-guru-default = "private-isu-aurora"
  }
  depends_on = [aws_rds_cluster.private_isu_db]
}
