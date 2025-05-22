# 概要
本セクションでは、AWSの基本的なコンピューティングサービスであるAmazon EC2インスタンスのみを使用して、Private-isuアプリケーションサーバーとベンチマーカーサーバーを構築します。この構成が、今後のパフォーマンスチューニングのベースラインとなります。

提供されたCloudFormationテンプレート (private-isu.yaml) では、VPC、サブネット、インターネットゲートウェイ、ルートテーブル、セキュリティグループ、そして2台のEC2インスタンス（アプリケーションサーバー、ベンチマーカーサーバー）とそれらに紐づくEIPが定義されています。

このワークショップでは、これらのリソースをTerraformで記述・管理するアプローチを取ります。

<details>
<summary>EC2のメリット</summary>
<ul>
<li><strong>柔軟なインスタンスタイプ:</strong> CPU、メモリ、ストレージ、ネットワーク容量の様々な組み合わせから、ワークロードに最適なインスタンスタイプを選択できます。</li>
<li><strong>スケーラビリティ:</strong> 必要に応じてインスタンス数を増減させたり、インスタンスタイプを変更したりすることが容易です。</li>
<li><strong>従量課金:</strong> 実際に使用したコンピューティング時間に対してのみ料金が発生します。</li>
<li><strong>OS選択の自由度:</strong> Linux、Windows Serverなど、様々なOSイメージを選択できます。</li>
<li><strong>フルコントロール:</strong> インスタンスに対する完全な制御権を持ち、OSレベルからの設定やソフトウェアのインストールが可能です。</li>
</ul>
</details>

# 構築手順
1. VPC、サブネット、EC2インスタンスなどを定義するTerraformファイル（例: main.tf, vpc.tf, ec2.tf）を作成し、編集していきます。

2. 以下は、基本的なネットワーク（VPC、サブネット、インターネットゲートウェイ、ルートテーブル）、セキュリティグループ、EC2インスタンス（アプリケーションサーバー、ベンチマーカー）を定義するTerraformコードのダミー例です。

<details>
<summary>Terraformコード例: ネットワークとEC2</summary>

```
# vpc.tf
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # 例: CloudFormationテンプレートの 192.168.0.0/16 とは異なる例を使用
  tags = {
    Name = "private-isu-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24" # 例: CloudFormationテンプレートの 192.168.1.0/24 とは異なる例を使用
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true # パブリックサブネット
  tags = {
    Name = "private-isu-public-subnet-a"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
    tags = {
        Name = "private-isu-igw"
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.gw.id
    }
     tags = {
        Name = "private-isu-public-rt"
    }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# security_group.tf
resource "aws_security_group" "web" {
  name        = "private-isu-web-sg"
  description = "Allow SSH, HTTP, HTTPS and Intra-VPC traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <TODO: 本来は自分のIPアドレスなどに制限します>
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443 // CloudFormationにはあるが、Private-isuのデフォルトでは未使用かも
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { // VPC内からの全トラフィック許可
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block] // <TODO: VPCのCIDRブロックを参照するようにしてください>
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-isu-web-sg"
  }
}

# ec2.tf
variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "<TODO: 自分のキーペア名を入力>"
}

variable "github_username" {
  description = "GitHub Username for SSH public key"
  type        = string
  default     = "<TODO: 自分のGitHubユーザー名を入力>"
}

resource "aws_instance" "app_server" {
  ami           = "<TODO: Private-isuアプリケーションサーバー用のAMI ID (例: ami-0d92a4724cae6f07b)>"
  instance_type = "t3.large" # CloudFormationでは c6i.large、コストを抑えるためt3.largeに変更
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  # private_ip    = "10.0.1.10" # CloudFormation のように固定も可能だが、動的に払い出されるように変更

  user_data = <<-EOF
    #!/bin/bash
    GITHUB_USER=${var.github_username}
    # UserDataの内容はCloudFormationテンプレートを参考にしてください
    # (isuconユーザーの作成、sshd設定、GitHub公開鍵の登録など)
    sudo yum update -y
    # <TODO: アプリケーションのセットアップスクリプトなどを記述>
  EOF

  tags = {
    Name = "private-isu-app-server"
  }
}

resource "aws_eip" "app_server_eip" {
  instance = aws_instance.app_server.id
  vpc      = true
  tags = {
    Name = "private-isu-app-server-eip"
  }
}

resource "aws_instance" "benchmarker" {
  ami           = "<TODO: Private-isuベンチマーカー用のAMI ID (例: ami-0582a2a7fbe79a30d)>"
  instance_type = "t3.xlarge" # CloudFormationでは c6i.xlarge、コストを抑えるためt3.xlargeに変更
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  # private_ip    = "10.0.1.20" # CloudFormation のように固定も可能だが、動的に払い出されるように変更

  user_data = <<-EOF
    #!/bin/bash
    GITHUB_USER=${var.github_username}
    # UserDataの内容はCloudFormationテンプレートを参考にしてください
    # (isuconユーザーの作成、sshd設定、GitHub公開鍵の登録など)
    sudo yum update -y
    # <TODO: ベンチマーカーのセットアップスクリプトなどを記述>
  EOF

  tags = {
    Name = "private-isu-benchmarker"
  }
}

resource "aws_eip" "benchmarker_eip" {
  instance = aws_instance.benchmarker.id
  vpc      = true
  tags = {
    Name = "private-isu-benchmarker-eip"
  }
}
```

</details>

3. 実行環境で terraform init を実行して初期化します。
    ```
    terraform init
    ```

4. 実行計画を確認します。
   ```
   terraform plan
   ```
    エラーが出ていないこと、意図したリソースが作成されることを確認して適用します。
    ```
    terraform apply
    ```

5. 動作確認
    各EC2インスタンスにEIP経由でSSH接続できることを確認します。  
    アプリケーションサーバーでPrivate-isuアプリケーションが起動していることを確認します。  
    ベンチマーカーからアプリケーションサーバーに対してベンチマークを実行し、初期スコアを記録します。  

6. ベンチマークの実行と考察
    初期構成でのベンチマークスコアを記録してください。これが今後の改善のベースラインとなります。

