locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.region.name
  env_name       = var.fargate_service_name_override == "" ? "${var.name}-${var.environment}" : var.fargate_service_name_override
  vpc_id         = data.aws_subnet.subnet.vpc_id

  # ECS
  ecs_cluster      = "arn:aws:ecs:${local.aws_region}:${local.aws_account_id}:cluster/${local.ecs_cluster_name}"
  ecs_cluster_name = var.ecs_cluster_name != null ? var.ecs_cluster_name : var.environment
  task_definition  = var.task_definition == "" ? local.env_name : var.task_definition

  # Tagging
  default_tags = {
    "Environment" : var.environment
    "Name" : local.env_name
    "Public" : var.is_public
    "Service" : var.service
  }
  tags = merge(var.custom_tags, local.default_tags)

}

# We use this to find the VPC ID to set up for the Security group. We use the first entry
# as a representative sample of the rest.
data "aws_subnet" "subnet" {
  id = var.service_subnets[0]
}

# Expose the account ID
data "aws_caller_identity" "current" {}

# Expose the region
data "aws_region" "region" {}
