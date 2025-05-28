# ====================================================
# 各サービス用エンドポイント
# ====================================================
# エンドポイント
## ECR用
resource "aws_vpc_endpoint" "samp_ecr_api" {
  vpc_id            = aws_vpc.samp_vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.samp_subnet_pri[0].id,
    aws_subnet.samp_subnet_pri[1].id,
    aws_subnet.samp_subnet_pri[2].id
  ]

  security_group_ids = [aws_security_group.vpc_endpoint.id]

  private_dns_enabled = true

  tags = {
    Name        = "${var.prefix}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "samp_ecr_dkr" {
  vpc_id            = aws_vpc.samp_vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.samp_subnet_pri[0].id,
    aws_subnet.samp_subnet_pri[1].id,
    aws_subnet.samp_subnet_pri[2].id
  ]

  security_group_ids = [aws_security_group.vpc_endpoint.id]

  private_dns_enabled = true

  tags = {
    Name        = "${var.prefix}-ecr-dkr"
  }
}

## CloudWatch Logs用
resource "aws_vpc_endpoint" "cwlogs" {
  vpc_id            = aws_vpc.samp_vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.samp_subnet_pri[0].id,
    aws_subnet.samp_subnet_pri[1].id,
    aws_subnet.samp_subnet_pri[2].id
  ]

  security_group_ids = [aws_security_group.vpc_endpoint.id]

  private_dns_enabled = true

  tags = {
    Name        = "${var.prefix}-cwlogs"
  }
}

## S3用
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.samp_vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.samp_rt_pri[0].id,
    aws_route_table.samp_rt_pri[1].id,
    aws_route_table.samp_rt_pri[2].id
  ]

  tags = {
    Name        = "${var.prefix}-s3"
  }
}

# エンドポイント用のセキュリティグループ
resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.prefix}-vpc-endpoint"
  vpc_id      = aws_vpc.samp_vpc.id

  ingress = [
    {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [var.vpc_cidr]
      description      = "for AWS VPC Endpoint"
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  tags = {
    Name        = "${var.prefix}-vpc-endpoint"
  }
}