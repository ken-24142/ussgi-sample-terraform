# ====================================================
# ALBのTarget Group
# ====================================================
# ALB
## Target Group
resource "aws_lb_target_group" "samp_web_tg_1" {
  name        = "tg-${var.prefix}-web-1"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.samp_vpc_id

  health_check {
    healthy_threshold   = 3
    interval            = 60
    path                = "/"
    timeout             = 30
    unhealthy_threshold = 5
  }

  tags = {
    Name = "${var.prefix}-tg-web-1"
  }
}

