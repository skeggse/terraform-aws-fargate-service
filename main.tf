## Fargate Task IAM Role
resource "aws_iam_role" "task" {
  name = "${local.env_name}-fg-role"
  assume_role_policy = file(
    "${path.module}/policies/ecs-assume-role-policy.json",
  )
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
}

module "task_definition" {
  source                   = "git@github.com:mixmaxhq/terraform-aws-ecs-task-definition?ref=v1.2.0"
  family                   = local.env_name
  name                     = local.env_name
  cpu                      = var.cpu
  memory                   = var.memory
  environment              = var.environment_vars
  image                    = var.image
  network_mode             = "awsvpc"
  portMappings             = local.port_mappings
  requires_compatibilities = ["FARGATE"]
  secrets                  = var.secrets
  tags                     = local.tags
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = "arn:aws:iam::${local.aws_account_id}:role/ecsTaskExecutionRole"

}

resource "aws_ecs_service" "service" {
  name            = local.env_name
  cluster         = local.ecs_cluster
  launch_type     = "FARGATE"
  task_definition = module.task_definition.arn
  desired_count   = 2

  dynamic "load_balancer" {
    for_each = var.load_balancer_config

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  network_configuration {
    subnets         = local.private_subnets
    security_groups = [aws_security_group.task.id]
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}
