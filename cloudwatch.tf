resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  resource_id        = "service/${var.environment}/${var.name}-${var.environment}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "up" {
  count              = var.scaling_enabled ? 1 : 0
  name               = "${var.name}-${var.environment}-scale-up"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.scale_up_adjustment
    }
  }
}

resource "aws_appautoscaling_policy" "down" {
  count              = var.scaling_enabled ? 1 : 0
  name               = "${var.name}-${var.environment}-scale-down"
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
  count               = var.scaling_enabled ? 1 : 0
  alarm_name          = "${var.name}-${var.environment}-cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.cpu_high_threshold

  alarm_description = "CPU high on ${var.name}-${var.environment}"

  alarm_actions = [aws_appautoscaling_policy.up[0].arn]

  dimensions = {
    ClusterName = var.environment
    ServiceName = "${var.name}-${var.environment}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count               = var.scaling_enabled ? 1 : 0
  alarm_name          = "${var.name}-${var.environment}-cpu-low-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.cpu_low_threshold

  alarm_description = "CPU low on ${var.name}-${var.environment}"

  alarm_actions = [aws_appautoscaling_policy.down[0].arn]

  dimensions = {
    ClusterName = var.environment
    ServiceName = "${var.name}-${var.environment}"
  }
}
