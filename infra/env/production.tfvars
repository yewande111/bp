# Production Environment Configuration
environment   = "production"
app_name      = "bp-calculator"
aws_region    = "eu-west-1"

# Instance Configuration
instance_type = "t3.micro"  # Free tier eligible in eu-west-1
min_instances = 1
max_instances = 4

# Application Configuration
health_check_path = "/"

# Monitoring
enable_cloudwatch_alarms = true
