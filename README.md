# AWSを利用したパフォーマンスチューニング体験

このハンズオンでは、**ISUCON**を題材として、AWSサービスを使用したWebアプリケーションのパフォーマンス改善を行っていきます。

リソースの可視化やスケーリング、サーバーレスアーキテクチャなどをIaCで実装しながら学べます。

このハンズオンに取り組むことで、以下のような項目をまとめて学べます:

- 実践的なWebサービスのAWSインフラへの理解
- ログやメトリクスを取得/分析する方法
- IaC (Terraform) を使った環境構築

## 目次

1. [CloudFormationで環境構築](./01-initial-environment/README.md)
1. [EC2のみでPrivate-isuの構築](./02-ec2-only-setup/README.md)
1. [AuroraへのDBの切り分け](./03-database-migration-to-aurora/README.md)
1. [ALBの追加](./04-adding-alb/README.md)
1. [Athenaでクエリ](./05-athena-log-analysis/README.md)
1. [CloudFrontによるキャッシュ](./06-cloudfront-caching/README.md)
1. [ElastiCacheによるキャッシュ](./07-elasticache-integration/README.md)
1. [EC2の複数台構成](./08-multi-ec2-instances/README.md)
1. [おまけ: コア数の増加](./09-multi-process/README.md)

またそれぞれのセクションのディレクトリに`private-isu-terraform`というディレクトリがあります。  
各セクションを完了した時のterraformファイル構成がありますので詰まった際にはそちらを参考に進めてください。