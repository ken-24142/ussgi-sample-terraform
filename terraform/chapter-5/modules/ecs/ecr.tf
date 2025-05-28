# ====================================================
# ECR
# ====================================================
# ECR
resource "aws_ecr_repository" "samp_web" {
  name = "${var.prefix}-repo-web"

  encryption_configuration {
    encryption_type = "KMS"
  }

}

## ECRのライフサイクルポリシー
resource "aws_ecr_lifecycle_policy" "samp_web" {
  repository = aws_ecr_repository.samp_web.id

  policy = jsonencode(
    {
      rules = [
        {
          description : "Keep only last 5 images"
          rulePriority : 1
          selection = {
            tagStatus : "any"
            countType : "imageCountMoreThan"
            countNumber : 5,
          }
          action = {
            type = "expire"
          }
        }
      ]
    }
  )

}
