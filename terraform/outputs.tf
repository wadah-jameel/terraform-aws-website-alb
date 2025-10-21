# Add these outputs to your existing outputs.tf

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "website_url" {
  description = "URL of the website"
  value       = "http://${aws_lb.main.dns_name}"
}

output "s3_bucket_name" {
  description = "Name of S3 bucket for website files"
  value       = aws_s3_bucket.website_files.bucket
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web_servers.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_servers.name
}
