output "task_role_arn" {
  description = "The ARN of the IAM Role created for the Fargate service"
  value       = aws_iam_role.task.arn
}

output "task_role_name" {
  description = "The name of the IAM Role created for the Fargate service"
  value       = aws_iam_role.task.name
}

output "task_sg_id" {
  description = "The ID of the Security Group attached to Fargate Tasks"
  value       = aws_security_group.task.id
}

output "cloudwatch_log_group_name" {
  description = "The name of the created CloudWatch log group"
  value       = module.cloudwatch_log_group.log_group_name
}
