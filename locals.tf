module "global_constants" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-global-constants.git?ref=v1.2.1"
}

data "aws_ecs_task_definition" "fargate_bootstrap" {
  task_definition = "fargate-bootstrap-${var.environment}"
}

locals {
  aws_account_id = module.global_constants.aws_account_id[var.environment]
  aws_region     = module.global_constants.aws_region[var.environment]
  vpc_id         = module.global_constants.vpc_id[var.environment]
  env_name       = "${var.name}-${var.environment}"

  # Networking
  private_subnets = module.global_constants.private_subnets[var.environment]
  service_subnets = length(var.service_subnets) == 0 ? local.private_subnets : var.service_subnets

  # ECS
  ecs_cluster      = "arn:aws:ecs:${local.aws_region}:${local.aws_account_id}:cluster/${var.environment}"
  ecs_cluster_name = var.environment
  task_definition  = var.task_definition == "" ? "${data.aws_ecs_task_definition.fargate_bootstrap.family}:${data.aws_ecs_task_definition.fargate_bootstrap.revision}" : var.task_definition

  # Tagging
  default_tags = {
    "Environment" : var.environment
    "Name" : var.name
    "Public" : var.is_public
    "Service" : var.service
  }
  tags = merge(var.custom_tags, local.default_tags)

}
