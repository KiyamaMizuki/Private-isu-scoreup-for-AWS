# 概要
本カリキュラムの各ステップを実行するためのAWS環境を構築します。このワークショップでは、パフォーマンスチューニングの各段階をTerraformを使用して進めていきますが、Terraform自体の実行環境やAWSクレデンシャルの設定など、コード記述以外の準備が必要となります。  

そこで、本セクションでは、受講者の皆様が迅速かつ均一な初期環境を準備できるよう、AWS CloudFormation を使用します。CloudFormationを利用することで、ローカル環境への特別なツールインストールや複雑な設定を行うことなく、提供されるYAMLファイルをAWSマネジメントコンソールにアップロードするだけで、必要なベース環境（VPC、EC2インスタンスなど）を自動的に構築できます。

このCloudFormationによって構築された環境が、後続のTerraformによるパフォーマンスチューニング作業の出発点となります。

<details>
<summary>CloudFormationのメリット</summary>
<ul>
<li><strong>インフラのコード化:</strong> インフラストラクチャをテンプレートファイル（JSONまたはYAML）で記述し、バージョン管理や再利用が可能です。</li>
<li><strong>自動化されたデプロイ:</strong> テンプレートに基づいてリソースを自動的にプロビジョニングおよび設定します。手動操作によるミスを削減し、デプロイ時間を短縮します。</li>
<li><strong>再現性と一貫性:</strong> 同じテンプレートを使用すれば、何度でも同じ環境を正確に再現できます。開発、ステージング、本番環境の一貫性を保つのに役立ちます。</li>
<li><strong>依存関係の管理:</strong> リソース間の依存関係を自動的に処理し、正しい順序で作成・削除します。</li>
<li><strong>簡便性:</strong> ローカルに特別な実行環境を構築する必要がなく、AWSマネジメントコンソールからテンプレートファイルをアップロードするだけで利用開始できます。</li>
</ul>
</details>

# 構築手順
1. CloudFormationテンプレートの準備
    ワークショップ主催者から提供されるCloudFormationテンプレートファイル（setup.yml） をお手元に準備してください。  
    <a href="https://raw.githubusercontent.com/KiyamaMizuki/Private-isu-scoreup-for-AWS/refs/heads/main/01-initial-environment/setup.yml" download="setup.yml">
  setup.yml をダウンロード
</a>  
    このテンプレートには、VPC、サブネット、セキュリティグループ、EC2インスタンス（アプリケーションサーバー、ベンチマーカーサーバー）などが定義されています。
2. AWSマネジメントコンソールへのログイン
    AWSマネジメントコンソールにログインし、CloudFormationを利用するリージョン（例: 東京リージョン ap-northeast-1）を選択していることを確認してください。
3. CloudFormationスタックの作成
    AWSマネジメントコンソールのサービス検索窓で「CloudFormation」と入力し、CloudFormationのダッシュボードを開きます。
    「スタックの作成」をクリックし、「新しいリソースを使用 (標準)」を選択します。
    ![](/images/CFn-make-stack.png)
4. 「既存のテンプレート」を選択し、「テンプレートファイルのアップロード」を選択し、先ほど用意したsetup.ymlを選択し「次へ」に進みます。
    ![](/images/CFn-upload-stack.png)
5. スタックの詳細を指定ではスタック名をcode-serverに指定して「次へ」で進みます。
    ![](/images/CFn-name-stack.png)
6. スタックオプションの設定では何も変更を加えず、「AWS CloudFormation によって IAM リソースが作成される場合があることを承認します。」にチェックを入れて「次へ」に進みます。
7. 確認して作成
    上記で設定した内容が反映されていることを確認し、「送信」を押します。

 [➡️ EC2のみでPrivate-isuの構築](../02-ec2-only-setup/README.md)