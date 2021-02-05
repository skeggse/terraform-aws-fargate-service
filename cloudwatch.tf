resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "up" {
  count              = var.cpu_scaling_enabled ? 1 : 0
  name               = "${local.env_name}-scale-up"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = "Average"

    # If we are between `cpu_high_threshold` and 1/3rd of maximum,
    # scale up by `scale_up_adjustment`.
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = (100 - var.cpu_high_threshold) / 3
      scaling_adjustment          = var.scale_up_adjustment
    }

    # If we are between 1/3rd and 2/3rds of the way between `cpu_high_threshold` and maximum (100%),
    # scale up by twice the `scale_up_adjustment`.
    step_adjustment {
      metric_interval_lower_bound = (100 - var.cpu_high_threshold) / 3
      metric_interval_upper_bound = ((100 - var.cpu_high_threshold) / 3) * 2
      scaling_adjustment          = var.scale_up_adjustment * 2
    }

    # If we are between 2/3rds of `cpu_high_threshold` and maximum (100%),
    # scale up by three times the `scale_up_adjustment`.
    step_adjustment {
      metric_interval_lower_bound = ((100 - var.cpu_high_threshold) / 3) * 2
      scaling_adjustment          = var.scale_up_adjustment * 3
    }
  }
}

resource "aws_appautoscaling_policy" "down" {
  count              = var.cpu_scaling_enabled ? 1 : 0
  name               = "${local.env_name}-scale-down"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_down_adjustment
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count               = var.cpu_scaling_enabled ? 1 : 0
  alarm_name          = "${local.env_name}-cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  tags                = local.tags

  alarm_description = "CPU high on ${local.env_name}"

  alarm_actions = [aws_appautoscaling_policy.up[0].arn]

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = local.env_name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count               = var.cpu_scaling_enabled ? 1 : 0
  alarm_name          = "${local.env_name}-cpu-low-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  tags                = local.tags

  alarm_description = "CPU low on ${local.env_name}"

  alarm_actions = [aws_appautoscaling_policy.down[0].arn]

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = local.env_name
  }
}

## Fargate Cloudwatch Log Group
# This needs to be provided to any task definition you manage and
# is created here for convenience.
module "cloudwatch_log_group" {
  source      = "git::ssh://git@github.com/mixmaxhq/terraform-aws-cloudwatch-log-group?ref=v2.0.0"
  name        = "/aws/fargate/${var.environment}/${local.env_name}"
  service     = var.service
  environment = var.environment
}
