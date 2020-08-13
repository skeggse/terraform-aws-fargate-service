variable "name" {
  description = "The name of the application to launch"
  type        = string
}

variable "environment" {
  description = "The environment to deploy into. Some valid values are production, staging, engineering."
  type        = string
}

variable "service" {
  description = "The name of the service this app is associated with; ie 'send' if the app was 'send-worker'"
  type        = string
}

variable "is_public" {
  description = "A boolean describing if the service is public or internal only. In this module, this is only used for tagging."
  type        = bool
  default     = false
}

variable "custom_tags" {
  description = "A mapping of custom tags to add to the generated resources."
  type        = map(string)
  default     = {}
}

variable "load_balancer_config" {
  description = "A list of objects describing load balancer configs: https://www.terraform.io/docs/providers/aws/r/ecs_service.html#load_balancer-1"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "service_subnets" {
  description = "A list of the subnet IDs to use with the service."
  type        = list(string)
}

variable "cpu_scaling_enabled" {
  description = "A boolean if CPU-based autoscaling should be turned on or off"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "The minimum number of tasks allowed to run at any given time."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The maximum number of tasks allowed to run at any given time."
  type        = number
  default     = 8
}

variable "scale_up_cooldown" {
  description = "The minimum amount of time in seconds between subsequent scale up events firing. This should be long enough to allow an app to start up, begin serving traffic, and get new aggregate averages of service load, but short enough to scale quickly and responsively."
  type        = number
  default     = 90
}

variable "scale_up_adjustment" {
  description = "The number of tasks to add during a scale up event. If a service sees high spiky load that needs immediate response times, it may be appropriate to nudge this up."
  type        = number
  default     = 1
}

variable "scale_down_cooldown" {
  description = "The minimum amount of time in seconds between subsequent scale down events firing. This should be somewhat longer than a scale up cooldown to prevent service degradation by quickly changing capacity, but being shorter does give us cost savings."
  type        = number
  default     = 300
}

variable "scale_down_adjustment" {
  description = "The number of tasks to stop during a scale down event. Be VERY CAREFUL changing this default. For example, if this was set to -2, and the service has 4 tasks running at present, scaling down would remove half the capacity of the service. If you want to scale down more aggressively, consider changing `scale_down_cooldown` instead."
  type        = number
  default     = -1
}

variable "cloudwatch_evaluation_periods" {
  description = "The number of times a metric must exceed thresholds before an alarm triggers. For example, if `period` is set to 60 seconds, and this is set to 2, a given threshold must have been exceeded twice over 120 seconds."
  type        = number
  default     = 2
}

variable "cloudwatch_period" {
  description = "The time in seconds CloudWatch alarms will consider a 'period'. By default, CloudWatch metrics only have a granularity of 60s, or in rare cases 180 or 300 seconds."
  type        = number
  default     = 60
}

variable "cpu_high_threshold" {
  description = "The CPU percentage to be considered 'high' for autoscaling purposes."
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "The CPU percentage to be considered 'low' for autoscaling purposes. This was set to a 'safe' value to prevent scaling down when it's not a good idea, but please adjust this higher for your app if possible."
  type        = number
  default     = 30
}

variable "task_definition" {
  description = "The family:revision or full ARN of the task definition to launch. If you are deploying software with Jenkins, you can ignore this; this is used with task definitions that are managed in Terraform. If unset, the first run will use an Nginx 'hello-world' task def. Terraform will not update the task definition in the service if this value has changed."
  type        = string
  default     = ""
}

variable "fargate_service_name_override" {
  description = "This parameter allows you to set to the Fargate service name explicitly. This is useful in cases where you need something other than the default {var.name}-{var.environment} naming convention"
  type        = string
  default     = ""
}

variable "capacity_provider_strategies" {
  description = "The capacity provider (supported by the configured cluster) to use to provision tasks for the service"
  type = list(object({
    capacity_provider = string
    base              = number
    weight            = number
  }))
  default = []
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster. If left blank, this module will use the `environment` variable as the ECS cluster name."
  type        = string
  default     = null
}

variable "health_check_grace_period" {
  description = "The load balancer health check grace period in seconds. This defines how long ECS will ignore failing load balancer checks on newly instantiated tasks. This is not required; additionally, this is only valid for services configured to use load balancers."
  type        = number
  default     = null
}
