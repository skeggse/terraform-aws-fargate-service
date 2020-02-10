locals {
  environment = "staging"
  app_name    = "terraform-aws-fargate-service-test"
  service     = "testing"
}

module "worker" {
  ## In a real app, use the following line instead of the relative module path:
  #source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service.git?ref=vX.X.X"
  source = "../.."

  name        = local.app_name
  service     = local.service
  environment = local.environment
}
