module "worker" {
  ## In a real app, use the following line instead of the relative module path:
  #source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service.git?ref=vX.X.X"
  source = "../.."

  name        = var.name
  service     = var.service
  environment = var.environment

  service_subnets = local.service_subnets

  # If you used `mixmax fargate bootstrap-service`, you probably want to
  # omit this value.
  task_definition = module.fargate_bootstrap_task_definition.arn
}

module "fargate_bootstrap_task_definition" {
  source                   = "git@github.com:mongodb/terraform-aws-ecs-task-definition?ref=v2.1.5"
  family                   = "fargate-bootstrap-${var.environment}"
  name                     = "fargate-bootstrap-${var.environment}"
  cpu                      = 256
  memory                   = 512
  image                    = "nginxdemos/hello"
  network_mode             = "awsvpc"
  portMappings             = [{ "containerPort" : 80 }]
  requires_compatibilities = ["FARGATE"]
  tags                     = { "Name" : "fargate-bootstrap", "Environment" : var.environment }
  execution_role_arn       = "arn:aws:iam::${local.aws_account_id}:role/ecsTaskExecutionRole"
}
