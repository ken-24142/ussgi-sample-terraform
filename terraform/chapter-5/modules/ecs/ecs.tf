# ====================================================
# ECS、Cluster、Service、Cloudwatch Log Group、Security Group
# ====================================================
# ECS
## ECS Cluster
resource "aws_ecs_cluster" "samp_cluster" {
    name = "${var.prefix}-ecs-cluster"

  setting { 
    name  = "containerInsights"
    value = "disabled"
  }
}

## ECS Service
resource "aws_ecs_service" "samp_service" {
  name                               = "${var.prefix}-ecs-service"
  cluster                            = aws_ecs_cluster.samp_cluster.id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  enable_execute_command             = true
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.samp_task.arn
  wait_for_steady_state              = false

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = "${var.prefix}-ecs-service"
    container_port   = 80
    target_group_arn = var.target_group_1_arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.samp_ecs.id]
    subnets          = [var.samp_subnet_pri_id_0, var.samp_subnet_pri_id_1, var.samp_subnet_pri_id_2]
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      load_balancer,
    ]
  }
}

## CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_log" {
  name              = "/ecs/${var.prefix}-ecs-service"
  retention_in_days = var.samp_log_retention_in_days
}

## Security Group
resource "aws_security_group" "samp_ecs" {
  name   = "${var.prefix}-ecs"
  vpc_id = var.samp_vpc_id

  ingress = [
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [var.samp_vpc_cidr]
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
    Name = "${var.prefix}-ecs"
  }
}