# `terraform-aws-fargate-service`

This module is a somewhat opinionated implementation of a Fargate service, without a load balancer. This is useful for creating a worker service, or a service where you will be configuring the load balancer yourself (for example, a super specific NLB or similar.)

For creating a Fargate service with a built-in application load balancer, see the [terraform-aws-fargate-service-with-lb module](https://github.com/mixmaxhq/terraform-aws-fargate-service-with-lb).

## Usage

An example deployable application can be found in the [examples/simple](examples/simple) directory.

## Notes

This module creates a security group (ie a firewall) for communicating with the service over the network. By default, it allows all traffic originating from the container (in other words, all `egress` traffic is allowed). However, if you would like to communicate inbound to the container from another service, you must create an [`aws_security_group_rule`](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html) resource referencing the Fargate service's security group. The module-created security group is available as the output `task_sg_id`. You can see an example of this in the terraform-aws-fargate-service-with-lb module.

Additionally, this module creates an IAM role for the Fargate service to authorize access to AWS resources. By default, these services get no permissions. To add permissions to an AWS resource, create an [`aws_iam_policy` resource](https://www.terraform.io/docs/providers/aws/r/iam_policy.html) and [attach the policy to the role using an `aws_iam_role_policy_attachment` resource](https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html). The module-created IAM role name is available as the output `task_role_name` from the module.

## Variables

### Required Variables

The following variables are required:

#### environment

Description: The environment to deploy into. Some valid values are production, staging, engineering.

Type:
`string`

#### image

Description: The image to launch. This is passed directly to the Docker engine. An example is 012345678910.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest

Type:
`string`

#### name

Description: The name of the service to launch

Type:
`string`

### Optional Variables

The following variables are optional (have default values):

#### cloudwatch\_evaluation\_periods

Description: The number of times a metric must exceed thresholds before an alarm triggers. For example, if `period` is set to 60 seconds, and this is set to 2, a given threshold must have been exceeded twice over 120 seconds.

Type:
`number`

Default:
`2`

#### cloudwatch\_period

Description: The time in seconds CloudWatch alarms will consider a 'period'. By default, CloudWatch metrics only have a granularity of 60s, or in rare cases 180 or 300 seconds.

Type:
`number`

Default:
`60`

#### container\_ports

Description: A list of ports the container listens on. Used for generating ECS Task Definition Container Definitions

Type:
`list(string)`

Default:
`[]`

#### cpu

Description: The CPU credits to provide container. 256 is .25 vCPUs, 1024 is 1 vCPU, max is 4096 (4 vCPUs). Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html

Type:
`number`

Default:
`256`

#### cpu\_high\_threshold

Description: The CPU percentage to be considered 'high' for autoscaling purposes.

Type:
`number`

Default:
`70`

#### cpu\_low\_threshold

Description: The CPU percentage to be considered 'low' for autoscaling purposes. This was set to a 'safe' value to prevent scaling down when it's not a good idea, but please adjust this higher for your app if possible.

Type:
`number`

Default:
`20`

#### custom\_tags

Description: A mapping of custom tags to add to the generated resources.

Type:
`map(string)`

Default:
`{}`

#### environment\_vars

Description: A list of maps of environment variables to provide to the container. Do not put secrets here; instead use the `secrets` input to specify the ARN of a Parameter Store or Secrets Manager value.

Type:
`list(map(string))`

Default:
`[]`

#### is\_public

Description: A boolean describing if the service is public or internal only. In this module, this is only used for tagging.

Type:
`bool`

Default:
`false`

#### load\_balancer\_config

Description: A list of objects describing load balancer configs: https://www.terraform.io/docs/providers/aws/r/ecs_service.html#load_balancer-1

Type:
```hcl
list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
```

Default:
`[]`

#### log\_config

Description: A logConfiguration as described in https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html . Default is nothing.

Type:
`any`

Default:
`{}`

#### max\_capacity

Description: The maximum number of tasks allowed to run at any given time.

Type:
`number`

Default:
`8`

#### memory

Description: The memory to provide the container in MiB. 512 is min, 30720 is max. Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html

Type:
`number`

Default:
`512`

#### min\_capacity

Description: The minimum number of tasks allowed to run at any given time.

Type:
`number`

Default:
`2`

#### scale\_down\_adjustment

Description: The number of tasks to stop during a scale down event. Be VERY CAREFUL changing this default. For example, if this was set to -2, and the service has 4 tasks running at present, scaling down would remove half the capacity of the service. If you want to scale down more aggressively, consider changing `scale_down_cooldown` instead.

Type:
`number`

Default:
`-1`

#### scale\_down\_cooldown

Description: The minimum amount of time in seconds between subsequent scale down events firing. This should be somewhat longer than a scale up cooldown to prevent service degradation by quickly changing capacity, but being shorter does give us cost savings.

Type:
`number`

Default:
`300`

#### scale\_up\_adjustment

Description: The number of tasks to add during a scale up event. If a service sees high spiky load that needs immediate response times, it may be appropriate to nudge this up.

Type:
`number`

Default:
`1`

#### scale\_up\_cooldown

Description: The minimum amount of time in seconds between subsequent scale up events firing. This should be long enough to allow an app to start up, begin serving traffic, and get new aggregate averages of service load, but short enough to scale quickly and responsively.

Type:
`number`

Default:
`90`

#### scaling\_enabled

Description: A boolean if autoscaling should be turned on or off

Type:
`bool`

Default:
`true`

#### secrets

Description: A list of maps of ARNs of secrets stored in Parameter Store or Secrets Manager and exposed as environment variables. Do not put actual secrets here! See examples/simple for usage.

Type:
`list(string)`

Default:
`[]`

#### task\_command

Description: The command to pass directly to the docker container, according to this syntax: https://docs.docker.com/engine/reference/builder/#cmd

Type:
`list(string)`

Default:
`[]`

## Outputs

The following outputs are exported:

#### task\_role\_name

Description: The ARN of the IAM Role created for the Fargate service

#### task\_sg\_id

Description: The ID of the Security Group attached to Fargate Tasks

