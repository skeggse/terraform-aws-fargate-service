## Fargate Task IAM Role
# This needs to be provided to any task definition you manage and
# is created here for convenience.
resource "aws_iam_role" "task" {
  name = "${local.env_name}-fg-role"
  assume_role_policy = file(
    "${path.module}/policies/ecs-assume-role-policy.json",
  )
  tags = merge(local.tags, { "Name" : "${local.env_name}-fg-role" })
}

## Fargate Task default security group
resource "aws_security_group" "task" {
  name        = "${local.env_name}-sg"
  description = "Security group for ${local.env_name}"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "Name" : "${local.env_name}-sg" })
}

resource "aws_ecs_service" "service" {
  name            = local.env_name
  cluster         = local.ecs_cluster
  launch_type     = "FARGATE"
  task_definition = local.task_definition
  desired_count   = 2
  tags            = local.tags
  propagate_tags  = "SERVICE"

  dynamic "load_balancer" {
    for_each = var.load_balancer_config

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  network_configuration {
    subnets         = local.service_subnets
    security_groups = [aws_security_group.task.id]
  }

  lifecycle {
    ignore_changes = ["desired_count", "task_definition"]
  }
}
