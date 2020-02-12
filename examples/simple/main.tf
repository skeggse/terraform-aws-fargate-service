module "worker" {
  ## In a real app, use the following line instead of the relative module path:
  #source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service.git?ref=vX.X.X"
  source = "../.."

  name        = var.name
  service     = var.service
  environment = var.environment
}
