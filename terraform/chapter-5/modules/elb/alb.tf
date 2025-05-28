# ====================================================
# ALB、Listener
# ====================================================
# ALB
resource "aws_lb" "samp_web" {
  name = "${var.prefix}-alb-web"
  subnets = [
    var.samp_subnet_pub_id_0,
    var.samp_subnet_pub_id_1,
    var.samp_subnet_pub_id_2
  ]
  security_groups = [aws_security_group.samp_alb_public.id]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.bucket
    prefix  = "${var.prefix}-log"
    enabled = true
  }

  depends_on = [
    aws_s3_bucket.alb_log
  ]

  tags = {
    Name = "${var.prefix}-alb-web"
  } 
}

## Listeners
resource "aws_lb_listener" "samp_web" {
  load_balancer_arn = aws_lb.samp_web.arn

  port       = 80

  default_action {
    order = 1
    type  = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  tags = {
    Name = "${var.prefix}-alb-web-listener"
  } 
}

## Listener Rule
resource "aws_lb_listener_rule" "samp_web_rule_1" {
  listener_arn = aws_lb_listener.samp_web.arn
  action {
    order            = 1
    target_group_arn = aws_lb_target_group.samp_web_tg_1.arn
    type             = "forward"
  }

  condition {
    path_pattern {
      values = [
        "/*",
      ]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }

  tags = {
    Name = "listener-rule-1"
  }
}

## Security Group
resource "aws_security_group" "samp_alb_public" {
  name   = "${var.prefix}-alb-pub"
  vpc_id = var.samp_vpc_id

  ingress = [
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [var.alb_source_ip_range]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      description      = ""
      self             = false
    },
  ]

  egress = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      description      = ""
      self             = false
    },
  ]

  tags = {
    Name = "${var.prefix}-alb-pub"
  }
}
