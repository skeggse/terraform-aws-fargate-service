variable "name" {
  description = "The name of the service to launch"
  type        = string
}

variable "environment" {
  description = "The environment to deploy into. Some valid values are production, staging, engineering."
  type        = string
}

variable "image" {
  description = "The image to launch. This is passed directly to the Docker engine. An example is 012345678910.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest"
  type        = string
}

variable "is_public" {
  description = "A boolean describing if the service is public or internal only. In this module, this is only used for tagging."
  type        = bool
  default     = false
}

variable "cpu" {
  description = "The CPU credits to provide container. 256 is .25 vCPUs, 1024 is 1 vCPU, max is 4096 (4 vCPUs). Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = number
  default     = 256
}

variable "memory" {
  description = "The memory to provide the container in MiB. 512 is min, 30720 is max. Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = number
  default     = 512
}

variable "environment_vars" {
  description = "A list of maps of environment variables to provide to the container. Do not put secrets here; instead use the `secrets` input to specify the ARN of a Parameter Store or Secrets Manager value."
  type        = list(map(string))
  default     = []
}

variable "secrets" {
  description = "A list of maps of ARNs of secrets stored in Parameter Store or Secrets Manager and exposed as environment variables. Do not put actual secrets here! See examples/simple for usage."
  type        = list(string)
  default     = []
}

variable "container_ports" {
  description = "A list of ports the container listens on. Used for generating ECS Task Definition Container Definitions"
  type        = list(string)
  default     = []
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

variable "scaling_enabled" {
  description = "A boolean if autoscaling should be turned on or off"
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
  default     = 20
}
