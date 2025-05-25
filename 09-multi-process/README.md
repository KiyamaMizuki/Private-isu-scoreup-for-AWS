# 概要
こちらはオマケセクションです。AWSリソースを用いたスコアアップではなくアプリケーションの設定を修正します。
これまでPrivate-isuをRubyで実装されたWebアプリケーションを利用し稼働させていました。  
Private-isuではuniconというサーバーライブラリが利用されています。uniconは1プロセスで1リクエストを処理する様なアーキテクチャになっています。

# 複数CPUを利用する為の設定
1. `~/private-isu/webapp/ruby/unicorn_config.rb`がuniconの設定ファイルパスになります。
    設定ファイルの初期状態は以下です。
    ```

    ```
    上記の`worker_processes`の値を4に変更してください
2. アプリの再起動
    `unicorn_config.rb`の編集後、アプリを再起動します。
    ```
    sudo systemctl restart isu-ruby
    ```

[⬅️ 前のセクションへ](../08-multi-ec2-instances/README.md)