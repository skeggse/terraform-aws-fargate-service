# `terraform-aws-fargate-service`

This module is a somewhat opinionated implementation of a Fargate service, without a load balancer. This is useful for creating a worker service, or a service where you will be configuring the load balancer yourself (for example, a super specific NLB or similar.)

For creating a Fargate service with a built-in application load balancer, see the [terraform-aws-fargate-service-with-lb module](https://github.com/mixmaxhq/terraform-aws-fargate-service-with-lb).

## Usage

An example deployable application can be found in the [examples/simple](examples/simple) directory.

## Notes

This module creates a security group (ie a firewall) for communicating with the service over the network. By default, it allows all traffic originating from the container (in other words, all `egress` traffic is allowed). However, if you would like to communicate inbound to the container from another service, you must create an [`aws_security_group_rule`](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html) resource referencing the Fargate service's security group. The module-created security group is available as the output `task_sg_id`. You can see an example of this in the terraform-aws-fargate-service-with-lb module.

Additionally, this module creates an IAM role for the Fargate service to authorize access to AWS resources. By default, these services get no permissions. To add permissions to an AWS resource, create an [`aws_iam_policy` resource](https://www.terraform.io/docs/providers/aws/r/iam_policy.html) and [attach the policy to the role using an `aws_iam_role_policy_attachment` resource](https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html). The module-created IAM role name is available as the output `task_role_name` from the module.

## Variables

<table>
<tr><th>Name</th><th>Description</th><th>Type</th><th>Default</th> <th>Required</th></tr>
<tr>
<td>container_ports</td>
<td>A list of ports the container listens on. Used for generating ECS Task Definition Container Definitions</td>
<td>

`list(string)`</td>
<td>

`[]`</td>
<td>no</td>
</tr>
<tr>
<td>cpu</td>
<td>The CPU credits to provide container. 256 is .25 vCPUs, 1024 is 1 vCPU, max is 4096 (4 vCPUs). Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html</td>
<td>

`number`</td>
<td>

`256`</td>
<td>no</td>
</tr>
<tr>
<td>custom_tags</td>
<td>A mapping of custom tags to add to the generated resources.</td>
<td>

`map(string)`</td>
<td>

`{}`</td>
<td>no</td>
</tr>
<tr>
<td>environment</td>
<td>The environment to deploy into. Some valid values are production, staging, engineering.</td>
<td>

`string`</td>
<td>

n/a</td>
<td>yes</td>
</tr>
<tr>
<td>environment_vars</td>
<td>A list of maps of environment variables to provide to the container. Do not put secrets here; instead use the `secrets` input to specify the ARN of a Parameter Store or Secrets Manager value.</td>
<td>

`list(map(string))`</td>
<td>

`[]`</td>
<td>no</td>
</tr>
<tr>
<td>image</td>
<td>The image to launch. This is passed directly to the Docker engine. An example is 012345678910.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest</td>
<td>

`string`</td>
<td>

n/a</td>
<td>yes</td>
</tr>
<tr>
<td>is_public</td>
<td>A boolean describing if the service is public or internal only. In this module, this is only used for tagging.</td>
<td>

`bool`</td>
<td>

`false`</td>
<td>no</td>
</tr>
<tr>
<td>load_balancer_config</td>
<td>A list of objects describing load balancer configs: https://www.terraform.io/docs/providers/aws/r/ecs_service.html#load_balancer-1</td>
<td>

```hcl
list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
```
</td>
<td>

`[]`</td>
<td>no</td>
</tr>
<tr>
<td>memory</td>
<td>The memory to provide the container in MiB. 512 is min, 30720 is max. Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html</td>
<td>

`number`</td>
<td>

`512`</td>
<td>no</td>
</tr>
<tr>
<td>name</td>
<td>The name of the service to launch</td>
<td>

`string`</td>
<td>

n/a</td>
<td>yes</td>
</tr>
<tr>
<td>secrets</td>
<td>A list of maps of ARNs of secrets stored in Parameter Store or Secrets Manager and exposed as environment variables. Do not put actual secrets here! See examples/simple for usage.</td>
<td>

`list(string)`</td>
<td>

`[]`</td>
<td>no</td>
</tr>
</table>

## Outputs

| Name | Description |
|------|-------------|
| task\_role\_name | The ARN of the IAM Role created for the Fargate service |
| task\_sg\_id | The ID of the Security Group attached to Fargate Tasks |

