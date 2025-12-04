# Main Terraform Configuration for BP Calculator
# Creates Elastic Beanstalk application with VPC, IAM roles, and CloudWatch monitoring

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# ============================================================================
# VPC AND NETWORKING
# ============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-${var.environment}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-${var.environment}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "eb_instance" {
  name        = "${var.app_name}-${var.environment}-eb-instance-sg"
  description = "Security group for Elastic Beanstalk instances"
  vpc_id      = aws_vpc.main.id

  # HTTP from anywhere (via load balancer)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP traffic"
  }

  # HTTPS from anywhere (via load balancer)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS traffic"
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-eb-instance-sg"
  }
}

# ============================================================================
# IAM ROLES AND POLICIES
# ============================================================================

# Service role for Elastic Beanstalk
resource "aws_iam_role" "eb_service_role" {
  name = "${var.app_name}-${var.environment}-eb-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-${var.environment}-eb-service-role"
  }
}

resource "aws_iam_role_policy_attachment" "eb_service_role_enhanced_health" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_service_role_managed_updates" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

# Instance role for EC2 instances
resource "aws_iam_role" "eb_instance_role" {
  name = "${var.app_name}-${var.environment}-eb-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-${var.environment}-eb-instance-role"
  }
}

resource "aws_iam_role_policy_attachment" "eb_instance_role_web_tier" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_instance_role_worker_tier" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "eb_instance_role_multicontainer" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

# CloudWatch Logs policy for application logs
resource "aws_iam_role_policy" "eb_instance_cloudwatch_logs" {
  name = "${var.app_name}-${var.environment}-cloudwatch-logs"
  role = aws_iam_role.eb_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${var.app_name}*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "${var.app_name}-${var.environment}-eb-instance-profile"
  role = aws_iam_role.eb_instance_role.name

  tags = {
    Name = "${var.app_name}-${var.environment}-eb-instance-profile"
  }
}

# ============================================================================
# S3 BUCKET FOR APPLICATION VERSIONS
# ============================================================================

resource "aws_s3_bucket" "app_versions" {
  bucket = "${var.app_name}-${var.environment}-app-versions-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.app_name}-${var.environment}-app-versions"
  }
}

resource "aws_s3_bucket_versioning" "app_versions" {
  bucket = aws_s3_bucket.app_versions.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "app_versions" {
  bucket = aws_s3_bucket.app_versions.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# ELASTIC BEANSTALK APPLICATION AND ENVIRONMENT
# ============================================================================

resource "aws_elastic_beanstalk_application" "app" {
  name        = "${var.app_name}-${var.environment}"
  description = "Blood Pressure Calculator - ${var.environment} environment"

  appversion_lifecycle {
    service_role          = aws_iam_role.eb_service_role.arn
    max_count             = 10
    delete_source_from_s3 = true
  }

  tags = {
    Name = "${var.app_name}-${var.environment}"
  }
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.app_name}-${var.environment}"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  tier                = "WebServer"

  # ============================================================================
  # VPC AND NETWORKING SETTINGS
  # ============================================================================

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.main.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", aws_subnet.public[*].id)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", aws_subnet.public[*].id)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  # ============================================================================
  # INSTANCE SETTINGS
  # ============================================================================

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_instance.id
  }

  # ============================================================================
  # AUTO SCALING SETTINGS
  # ============================================================================

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.min_instances
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.max_instances
  }

  # ============================================================================
  # LOAD BALANCER SETTINGS
  # ============================================================================

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = var.health_check_path
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "5000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  # ============================================================================
  # ENVIRONMENT SETTINGS
  # ============================================================================

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ASPNETCORE_ENVIRONMENT"
    value     = var.environment == "production" ? "Production" : "Staging"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOTNET_RUNNING_IN_CONTAINER"
    value     = "true"
  }

  # ============================================================================
  # CLOUDWATCH LOGS
  # ============================================================================

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
  }

  # ============================================================================
  # ENHANCED HEALTH REPORTING
  # ============================================================================

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "EnhancedHealthAuthEnabled"
    value     = "true"
  }

  # ============================================================================
  # MANAGED PLATFORM UPDATES
  # ============================================================================

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "Sun:03:00"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor"
  }

  # ============================================================================
  # DEPLOYMENT SETTINGS
  # ============================================================================

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "50"
  }

  # ============================================================================
  # SERVICE ROLE
  # ============================================================================

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service_role.arn
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-env"
  }
}

# ============================================================================
# CLOUDWATCH ALARMS (Optional)
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.app_name}-${var.environment}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "EnvironmentHealth"
  namespace           = "AWS/ElasticBeanstalk"
  period              = "300"
  statistic           = "Average"
  threshold           = "15"
  alarm_description   = "Triggers when environment health is degraded"
  treat_missing_data  = "notBreaching"

  dimensions = {
    EnvironmentName = aws_elastic_beanstalk_environment.env.name
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-unhealthy-hosts-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_errors" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.app_name}-${var.environment}-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApplicationRequests5xx"
  namespace           = "AWS/ElasticBeanstalk"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Triggers when 5xx error count exceeds threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    EnvironmentName = aws_elastic_beanstalk_environment.env.name
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-5xx-errors-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.app_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Triggers when CPU utilization exceeds 80%"
  treat_missing_data  = "notBreaching"

  tags = {
    Name = "${var.app_name}-${var.environment}-high-cpu-alarm"
  }
}
