# 概要
![06](../images/Private-isu06.png) 
本セクションでは、Amazon CloudFront を導入し、静的ファイル（CSS, JavaScript, 一部の画像など）をエッジロケーションにキャッシュすることで、オリジンサーバー（ALB経由のEC2）への負荷を軽減し、ユーザーへのレスポンス速度を向上させます。

<details>
<summary>CloudFrontのメリット</summary>
<ul>
<li><strong>高速なコンテンツ配信:</strong> 世界中に分散されたエッジロケーションからコンテンツを配信し、レイテンシを低減します。</li>
<li><strong>オリジン負荷軽減:</strong> キャッシュによりオリジンサーバーへのリクエスト数を削減します。</li>
<li><strong>セキュリティ:</strong> AWS Shield StandardによるDDoS緩和が自動的に有効。AWS WAFとの統合も容易です。</li>
<li><strong>コスト削減:</strong> データ転送量やオリジンへのリクエスト数を削減することでコストを最適化できます。</li>
<li><strong>カスタマイズ可能:</strong> キャッシュ動作、SSL証明書、地理的制限など、柔軟な設定が可能です。</li>
</ul>
</details>

# 構築手順
1. CloudFrontディストリビューションを定義するTerraformファイル（例: cloudfront.tf）を作成します。

2. 以下は、CloudFrontディストリビューションを定義するTerraformコードです。オリジンは前のステップで作成したALBを指定します。

    <details>
    <summary>CloudFront</summary>

    ```
    resource "aws_cloudfront_vpc_origin" "alb" {
    vpc_origin_endpoint_config {
        name                   = "alb-origin"
        arn                    = aws_lb.private_isu_alb.arn
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"

        origin_ssl_protocols {
        items    = ["TLSv1.2"]
        quantity = 1
        }
    }
    }

    resource "aws_cloudfront_distribution" "alb" {
    origin {
        domain_name = aws_lb.private_isu_alb.dns_name
        origin_id   = "alb-origin"
        vpc_origin_config {
        vpc_origin_id = aws_cloudfront_vpc_origin.alb.id
        }
    }

    enabled = true

    default_cache_behavior {
        viewer_protocol_policy   = "allow-all"
        allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods           = ["GET", "HEAD"]
        cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
        target_origin_id         = "alb-origin"
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Managed-AllViewer
    }

    ordered_cache_behavior {
        path_pattern     = "/favicon.ico"
        target_origin_id = "alb-origin"

        viewer_protocol_policy = "allow-all"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }
    ordered_cache_behavior {
        path_pattern     = "/js/*"
        target_origin_id = "alb-origin"

        viewer_protocol_policy = "allow-all"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }
    ordered_cache_behavior {
        path_pattern     = "/css/*"
        target_origin_id = "alb-origin"

        viewer_protocol_policy = "allow-all"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }
    ordered_cache_behavior {
        path_pattern     = "/image/*"
        target_origin_id = "alb-origin"

        viewer_protocol_policy = "allow-all"
        allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods         = ["GET", "HEAD"]
        cache_policy_id        = aws_cloudfront_cache_policy.image.id
    }

    price_class = "PriceClass_All"

    restrictions {
        geo_restriction {
        restriction_type = "none"
        locations        = []
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
    }

    resource "aws_cloudfront_cache_policy" "image" {
    name = "image-cache-policy"

    default_ttl = 60
    max_ttl     = 60
    min_ttl     = 60

    parameters_in_cache_key_and_forwarded_to_origin {
        cookies_config {
        cookie_behavior = "none"
        }

        headers_config {
        header_behavior = "none"
        }

        query_strings_config {
        query_string_behavior = "none"
        }
    }
    }

    ```

3. 実行計画を確認し、適用します。
    ```
    terraform plan
    terraform apply
    ```
    
4. 動作確認
    CloudFrontディストリビューションのドメイン名（例: xxxxxx.cloudfront.net）にアクセスし、アプリケーションが表示されることを確認します。

5. ベンチマークの実行と考察
    CloudFront経由でベンチマークを実行し、スコアを比較してください。特に静的コンテンツの多いページでのレスポンス速度向上や、オリジンサーバーの負荷軽減効果を考察しましょう。