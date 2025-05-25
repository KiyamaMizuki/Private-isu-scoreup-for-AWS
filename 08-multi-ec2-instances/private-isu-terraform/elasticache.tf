resource "aws_elasticache_cluster" "isucon_memcached" {
  cluster_id           = "isucon-memcached"             
  engine               = "memcached"              
  engine_version       = "1.6.22"                 
  node_type            = "cache.t3.micro"         
  num_cache_nodes      = 1                       
  port                 = 11211                    
  parameter_group_name = "default.memcached1.6"   
  subnet_group_name    = aws_elasticache_subnet_group.memcached_subnet_group.name 
  security_group_ids   = [aws_security_group.isucon_memcached_sg.id]
  apply_immediately = true
  tags = {
    Name = "isucon-mem"
  }

  depends_on = [
    aws_elasticache_subnet_group.memcached_subnet_group,
  ]
}

# --- ElastiCache サブネットグループの作成 ---
resource "aws_elasticache_subnet_group" "memcached_subnet_group" {
  name       = "isucon-mem-subnet-group"
  subnet_ids =  [aws_subnet.cache_subnet.id]

  tags = {
    Name = "isucon-mem-subnet-group"
  }
}
