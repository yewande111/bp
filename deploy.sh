#!/bin/bash

###############################################################################
# BP Calculator - Deployment Script
# Usage: ./deploy.sh [staging|production|all]
# 
# Description:
#   Deploys BP Calculator infrastructure using Terraform to AWS Elastic Beanstalk.
#   Supports separate staging and production environments with independent state files.
#
# Prerequisites:
#   - Terraform installed (v1.0+)
#   - AWS CLI installed and configured
#   - AWS credentials with appropriate permissions
#   - S3 backend bucket for Terraform state (bp-terraform-state-<account-id>)
#
# Environments:
#   - staging: Single t3.micro instance for testing
#   - production: Auto-scaled t3.micro instances (min 1, max 3)
#
# Last Updated: December 2025
###############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${SCRIPT_DIR}/infra"

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure'."
        exit 1
    fi
    
    # Check if infra directory exists
    if [ ! -d "$INFRA_DIR" ]; then
        print_error "Infrastructure directory not found at: $INFRA_DIR"
        exit 1
    fi
    
    print_success "All prerequisites met"
}

deploy_environment() {
    local ENV=$1
    
    print_header "Deploying $ENV Environment"
    
    cd "$INFRA_DIR"
    
    # Initialize Terraform with correct backend
    print_info "Initializing Terraform for $ENV..."
    terraform init -backend-config="env/${ENV}.backend.tfvars" -reconfigure
    
    # Validate configuration
    print_info "Validating Terraform configuration..."
    terraform validate
    
    # Plan deployment
    print_info "Planning deployment..."
    terraform plan -var-file="env/${ENV}.tfvars" -out="${ENV}.tfplan"
    
    # Ask for confirmation
    echo ""
    print_warning "Ready to apply changes to $ENV environment"
    read -p "Do you want to proceed? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_error "Deployment cancelled by user"
        rm -f "${ENV}.tfplan"
        exit 1
    fi
    
    # Apply deployment
    print_info "Applying deployment..."
    terraform apply "${ENV}.tfplan"
    
    # Clean up plan file
    rm -f "${ENV}.tfplan"
    
    # Get outputs
    print_info "Deployment outputs:"
    terraform output
    
    print_success "$ENV environment deployed successfully!"
    
    # Return to script directory
    cd "$SCRIPT_DIR"
}

show_usage() {
    echo "Usage: $0 [staging|production|all]"
    echo ""
    echo "Examples:"
    echo "  $0 staging       # Deploy staging environment"
    echo "  $0 production    # Deploy production environment"
    echo "  $0 all          # Deploy both environments"
    echo ""
}

###############################################################################
# Main Script
###############################################################################

# Check if environment argument is provided
if [ $# -eq 0 ]; then
    print_error "No environment specified"
    show_usage
    exit 1
fi

ENV=$1

# Check prerequisites
check_prerequisites

# Deploy based on argument
case $ENV in
    staging)
        deploy_environment "staging"
        ;;
    production)
        deploy_environment "production"
        ;;
    all)
        deploy_environment "staging"
        echo ""
        deploy_environment "production"
        ;;
    *)
        print_error "Invalid environment: $ENV"
        show_usage
        exit 1
        ;;
esac

print_header "Deployment Complete"
print_success "All deployments completed successfully!"
echo ""
print_info "Environment URLs:"
if [ "$ENV" = "staging" ] || [ "$ENV" = "all" ]; then
    echo "  Staging: http://bp-calculator-staging.eu-west-1.elasticbeanstalk.com"
fi
if [ "$ENV" = "production" ] || [ "$ENV" = "all" ]; then
    echo "  Production: http://bp-calculator-production.eu-west-1.elasticbeanstalk.com"
fi
echo ""
print_info "Next steps:"
echo "  1. Verify application is running (wait 2-3 minutes for EB initialization)"
echo "  2. Test all blood pressure categories (Normal, Elevated, Stage 1, Stage 2)"
echo "  3. Check CloudWatch logs at: https://console.aws.amazon.com/cloudwatch/"
echo "  4. Monitor environment health in AWS Console"
echo ""
print_info "Deployment artifacts saved in S3:"
echo "  s3://bp-calculator-eb-artifacts-${ENV}/"
echo ""
