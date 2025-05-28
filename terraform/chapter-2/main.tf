# ====================================================
# IAM Policy (テスト作成)
# ====================================================
resource "aws_iam_policy" "policy" {
  name        = "samp_test_policy"
  description = "sample test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# ====================================================
# 環境設定（共通）
# ====================================================
terraform {
  required_version = "~> 1.11.0"

  backend "s3" {
    bucket = "test-terraform-012345678901" # 前準備で作成したS3バケット名へ変更
    key    = "tf-test-2024.tfstate"
    region = "ap-northeast-1" # 前準備で作成したS3バケットのリージョンへ変更
  }
}

provider "aws" {
  region = "ap-northeast-1"

  allowed_account_ids = [
    "012345678901" # 今回リソースを作成するAWSアカウントIDへ変更
  ]

  default_tags {
    tags = {Env = "sample-test"}
  }
}
