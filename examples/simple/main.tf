locals {
  environment = "staging"
  app_name    = "terraform-aws-fargate-service-test"
  image       = "nginxdemos/hello"
}

module "worker" {
  source      = "../.."
  environment = local.environment
  name        = local.app_name
  image       = local.image
  cpu         = 256
  memory      = 512
  log_config = {
    "logDriver" : "awslogs",
    "options" : {
      "awslogs-group" : "/aws/fargate/${local.environment}",
      "awslogs-stream-prefix" : local.app_name,
      "awslogs-region" : "us-east-1"
    }
  }

  environment_vars = [{ "name" : "MY_SPECIAL_VAR", "value" : "PLAINTEXT_VALUE" }]
}
