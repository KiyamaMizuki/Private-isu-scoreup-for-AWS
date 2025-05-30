# 概要
![07](../images/private-isu07.png)  
本セクションでは、Amazon ElastiCacheを導入し、アプリケーションレベルのキャッシュ（セッション情報、頻繁にアクセスされるDBクエリ結果など）を切り離します。これにより、DBへの負荷を軽減し、アプリケーションのレスポンスを高速化します。また、この後の複数台構成において、ステートフルな情報を外部に持つための準備でもあります。

<details>
<summary>ElastiCacheのメリット</summary>
<ul>
<li><strong>高速パフォーマンス:</strong> インメモリデータストアにより、マイクロ秒単位のレイテンシを実現します。</li>
<li><strong>運用負荷軽減:</strong> ハードウェアプロビジョニング、パッチ適用、バックアップなどの管理タスクが自動化されます。</li>
<li><strong>スケーラビリティ:</strong> ニーズに応じてクラスターのノード数やノードタイプを容易に変更できます。</li>
<li><strong>エンジン選択:</strong> Memcached (シンプルなKVS) と Redis (多機能なデータ構造) の2つのエンジンから選択可能です。</li>
<li><strong>高可用性 (Redis):</strong> RedisクラスターモードやマルチAZレプリケーションにより可用性を高められます。</li>
</ul>
</details>

# 環境構築
1. ElastiCacheクラスター、サブネットグループ、セキュリティグループなどを定義するTerraformファイル（elasticache.tf）を作成します。  
    Private-isuがMemcachedを使用している為ここでもMemcachedを構築していきます。

2. 以下は、ElastiCache (Memcached) 関連リソースを定義するTerraformコードです。
    <details>
    <summary>elasticache.tf</summary>

    ```
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
      apply_immediately    = true
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
      subnet_ids = [aws_subnet.cache_subnet.id]

      tags = {
        Name = "isucon-mem-subnet-group"
      }
    }
    ```

    </details>

    <details>
    <summary>sg.tf</summary>

    ```
    #memcached用リソース
    resource "aws_security_group" "isucon_memcached_sg" {
        name   = "isucon_memcached_sg"
        vpc_id = aws_vpc.vpc.id
        ingress {
            from_port       = 11211
            to_port         = 11211
            protocol        = "tcp"
            security_groups = [aws_security_group.private_isu_web.id]
        }
    }
    ```
    </details>

    <details>
    <summary>vpc.tf</summary>

    ```
    # memcached用サブネット
    resource "aws_subnet" "cache_subnet" {
        vpc_id = aws_vpc.vpc.id

        availability_zone = "us-east-1c"
        cidr_block        = "10.10.5.0/24"
    }
    ```
    </details>

3. 実行計画を確認し、適用します。
    ```
    terraform plan
    terraform apply
    ```
    ※ElastiCacheの作成には時間がかかります。

4. アプリケーションの変更
    Private-isuインスタンスに入ってキャッシュの向き先を変更します。 `~/env.sh`ファイルを開き以下の様に編集します。
     ```
    PATH=/usr/local/bin:/home/isucon/.local/ruby/bin:/home/isucon/.local/node/bin:/home/isucon/.local/python3/bin:/home/isucon/.local/perl/bin:/home/isucon/.local/php/bin:/home/isucon/.local/php/sbin:/home/isucon/.local/go/bin:/home/isucon/.local/scala/bin:/usr/bin/:/bin/:$PATH
    ISUCONP_DB_USER=isuconp
    ISUCONP_DB_PASSWORD=password
    ISUCONP_DB_NAME=isuconp
    ISUCONP_DB_HOST=<Auroraのエンドポイント>
    ISUCONP_MEMCACHED_ADDRESS=<ElastiCacheのエンドポイント> # 追加
    ```
    
    Private-isuアプリを再起動してください。
    ```
    sudo systemctl daemon-reload
    sudo systemctl restart isu-ruby
    ```

5. ベンチマークの実行と考察  
    ElastiCache導入後、再度ベンチマークを実行し、スコアを比較してください。

[⬅️ 前のセクションへ](../06-cloudfront-caching/README.md)　　　[次のセクションへ ➡️](../08-multi-ec2-instances/README.md)
