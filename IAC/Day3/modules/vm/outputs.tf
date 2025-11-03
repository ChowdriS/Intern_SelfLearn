output "security_group_id" {
  description = "Security group ID for web servers"
  value       = aws_security_group.web_sg.id
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.web_lt.id
}

output "autoscaling_group_name" {
  description = "ASG name"
  value       = aws_autoscaling_group.web_asg.name
}
