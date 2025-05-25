terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = [""] #あなたの発行したAWSアカウントのIDを入力してください
  default_tags {
    tags = {
      TerraformName = "CTOA-aws-handsON"
    }
  }
}
