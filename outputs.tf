
output "alb_dns_name" {
    
    description = "The public DNS name of the load balancer"
    value = aws_lb.main.dns_name
}

output "rds_endpoint" {
    description = "The connection endpoint for the RDS instance"
    value = aws_db_instance.main.address
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM Role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}