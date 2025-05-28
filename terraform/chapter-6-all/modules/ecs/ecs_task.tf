# ====================================================
# ECS Task、Task Role、Task Execution Role
# ====================================================
# ECS Task
resource "aws_ecs_task_definition" "samp_task" {
  family       = "${var.prefix}-ecs-service"
  network_mode = "awsvpc"
  container_definitions = jsonencode([
    {
      name  = "${var.prefix}-ecs-service"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        },
      ]
    }
  ])
  cpu                = var.samp_ecs_task_cpu
  memory             = var.samp_ecs_task_memory
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  requires_compatibilities = [
    "FARGATE",
  ]
  task_role_arn = aws_iam_role.ecs_task.arn
}


# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name               = "${var.prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ssm_logs_for_ecs_task" {
  name   = "${var.prefix}-ssm-logs-for-ecs-task-role"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ssm_logs_for_ecs_task.json
}

data "aws_iam_policy_document" "ssm_logs_for_ecs_task" {
  ### ECS Execの利用
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]

    effect = "Allow"
  }

  ### Cloudwatch Logsの利用
  statement {
    actions = [
      "logs:*",
    ]

    resources = ["*"]

    effect = "Allow"
  }
}


## ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.prefix}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution.json
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ssm_for_ecs_task_execution" {
  name   = "${var.prefix}-ssm-for-ecs-task-execution-role"
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy_document.ssm_for_ecs_task_execution.json
}

data "aws_iam_policy_document" "ssm_for_ecs_task_execution" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = ["*"]
  }
}
