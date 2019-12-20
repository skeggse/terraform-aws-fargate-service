module "global_constants" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-global-constants.git?ref=v1.2.1"
}

locals {
  aws_account_id   = module.global_constants.aws_account_id[var.environment]
  aws_region       = module.global_constants.aws_region[var.environment]
  vpc_id           = module.global_constants.vpc_id[var.environment]
  env_name         = "${var.name}-${var.environment}"
  private_subnets  = module.global_constants.private_subnets[var.environment]
  ecs_cluster      = "arn:aws:ecs:${local.aws_region}:${local.aws_account_id}:cluster/${var.environment}"
  ecs_cluster_name = var.environment
  default_tags = {
    "Environment" : var.environment
    "Name" : var.name
    "Public" : var.is_public
  }
  tags = merge(local.default_tags, var.custom_tags)

  port_mappings = [
    for port in var.container_ports : { "containerPort" : port }
  ]
}
