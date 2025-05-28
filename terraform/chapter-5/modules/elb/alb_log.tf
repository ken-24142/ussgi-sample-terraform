# ====================================================
# ALBのアクセスログを保存するS3バケット
# ====================================================
# ALB
data "aws_caller_identity" "current" {}  # 現在のAWSアカウントIDを取得
data "aws_elb_service_account" "main" {}  # ELBサービスアカウントを取得

## S3 Bucket for ALB Logs
resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "alb-log-${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id     = "manage-alb-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"  
    }

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log_policy" {
  bucket = aws_s3_bucket.alb_log.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowELBAccessToS3LoggingBucket",
        Effect = "Allow",
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.alb_log.arn}/${var.prefix}-log/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}
