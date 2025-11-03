output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_alb.alb.dns_name
}

output "sg_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = aws_alb_target_group.app_tg.arn
}
