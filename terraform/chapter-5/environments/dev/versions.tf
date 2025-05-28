# ====================================================
# 環境設定（共通）
# ====================================================
terraform {
  required_version = "~> 1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.96.0"
    }
  }

  backend "s3" {
    bucket         = "test-terraform-012345678901" # 前準備で作成したS3バケット名
    key            = "tf-test-2025.tfstate"
    region         = "ap-northeast-1" # 前準備で作成したS3バケットのリージョン
    use_lockfile   = true
  }
}

provider "aws" {
  region = "ap-northeast-1"

  allowed_account_ids = [
    "012345678901" # 今回リソースを作成するAWSアカウントID
  ]

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "samp-pj"
    }
  }
}

