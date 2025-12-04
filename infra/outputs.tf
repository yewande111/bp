# Terraform Outputs for BP Calculator Infrastructure

output "application_name" {
  description = "Elastic Beanstalk application name"
  value       = aws_elastic_beanstalk_application.app.name
}

output "environment_name" {
  description = "Elastic Beanstalk environment name"
  value       = aws_elastic_beanstalk_environment.env.name
}

output "environment_url" {
  description = "URL of the Elastic Beanstalk environment"
  value       = "http://${aws_elastic_beanstalk_environment.env.cname}"
}

output "environment_cname" {
  description = "CNAME of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.env.cname
}

output "app_versions_bucket" {
  description = "S3 bucket name for application versions"
  value       = aws_s3_bucket.app_versions.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "security_group_id" {
  description = "Security group ID for Elastic Beanstalk instances"
  value       = aws_security_group.eb_instance.id
}

output "service_role_arn" {
  description = "IAM service role ARN for Elastic Beanstalk"
  value       = aws_iam_role.eb_service_role.arn
}

output "instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  value       = aws_iam_instance_profile.eb_instance_profile.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for application logs"
  value       = "/aws/elasticbeanstalk/${aws_elastic_beanstalk_environment.env.name}/var/log/eb-engine.log"
}

output "environment_id" {
  description = "Elastic Beanstalk environment ID"
  value       = aws_elastic_beanstalk_environment.env.id
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = aws_elastic_beanstalk_environment.env.load_balancers
}
