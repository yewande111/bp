#!/bin/bash

###############################################################################
# BP Calculator - Destroy Script
# Usage: ./destroy.sh [staging|production|all] [--auto-approve]
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
AUTO_APPROVE=false

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

destroy_environment() {
    local ENV=$1
    
    print_header "Destroying $ENV Environment"
    
    # Warning message
    print_warning "THIS WILL PERMANENTLY DELETE ALL RESOURCES IN $ENV ENVIRONMENT!"
    echo ""
    print_warning "Resources to be destroyed:"
    echo "  - Elastic Beanstalk environment"
    echo "  - EC2 instances"
    echo "  - Load balancers"
    echo "  - Security groups"
    echo "  - S3 artifact bucket"
    echo "  - CloudWatch log groups"
    echo "  - IAM roles"
    echo ""
    
    if [ "$AUTO_APPROVE" = false ]; then
        read -p "Type 'DELETE-$ENV' to confirm destruction: " confirm
        
        if [ "$confirm" != "DELETE-$ENV" ]; then
            print_error "Destruction cancelled by user"
            exit 1
        fi
    fi
    
    cd "$INFRA_DIR"
    
    # Initialize Terraform with correct backend
    print_info "Initializing Terraform for $ENV..."
    terraform init -backend-config="env/${ENV}.backend.tfvars" -reconfigure
    
    # Backup state file
    print_info "Backing up Terraform state..."
    terraform state pull > "${SCRIPT_DIR}/backup-${ENV}-state-$(date +%Y%m%d-%H%M%S).json"
    
    # Destroy infrastructure
    print_info "Destroying infrastructure..."
    if [ "$AUTO_APPROVE" = true ]; then
        terraform destroy -var-file="env/${ENV}.tfvars" -auto-approve
    else
        terraform destroy -var-file="env/${ENV}.tfvars"
    fi
    
    print_success "$ENV environment destroyed successfully!"
    
    # Return to script directory
    cd "$SCRIPT_DIR"
}

cleanup_artifact_buckets() {
    print_header "Cleaning Up Artifact Buckets"
    
    print_warning "This will delete all S3 artifact buckets and their contents"
    
    if [ "$AUTO_APPROVE" = false ]; then
        read -p "Do you want to delete artifact buckets? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            print_info "Skipping artifact bucket cleanup"
            return
        fi
    fi
    
    # Get account ID
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    
    # List and delete artifact buckets
    print_info "Searching for artifact buckets..."
    buckets=$(aws s3 ls | grep "bp-calculator-eb-artifacts" | awk '{print $3}' || true)
    
    if [ -z "$buckets" ]; then
        print_info "No artifact buckets found"
        return
    fi
    
    for bucket in $buckets; do
        print_info "Emptying bucket: $bucket"
        aws s3 rm "s3://$bucket" --recursive || true
        
        print_info "Deleting bucket: $bucket"
        aws s3 rb "s3://$bucket" || true
    done
    
    print_success "Artifact buckets cleaned up"
}

cleanup_terraform_backend() {
    print_header "Cleaning Up Terraform Backend"
    
    print_warning "THIS WILL DELETE TERRAFORM STATE FILES AND BACKEND RESOURCES!"
    print_warning "Only do this after ALL environments are destroyed"
    echo ""
    print_warning "Resources to be deleted:"
    echo "  - S3 bucket: bp-terraform-state-431774613177"
    echo "  - DynamoDB table: bp-terraform-locks"
    echo "  - All Terraform state files"
    echo ""
    
    if [ "$AUTO_APPROVE" = false ]; then
        read -p "Type 'DELETE-BACKEND' to confirm backend deletion: " confirm
        if [ "$confirm" != "DELETE-BACKEND" ]; then
            print_info "Skipping backend cleanup"
            return
        fi
    fi
    
    # Get account ID for bucket name
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    BUCKET_NAME="bp-terraform-state-${ACCOUNT_ID}"
    
    print_info "Emptying Terraform state bucket..."
    aws s3 rm "s3://$BUCKET_NAME" --recursive || true
    
    print_info "Deleting Terraform state bucket..."
    aws s3 rb "s3://$BUCKET_NAME" || true
    
    print_info "Deleting DynamoDB table..."
    aws dynamodb delete-table --table-name bp-terraform-locks --region eu-west-1 || true
    
    print_success "Terraform backend cleaned up"
}

show_usage() {
    echo "Usage: $0 [staging|production|all] [--auto-approve]"
    echo ""
    echo "Arguments:"
    echo "  staging              Destroy staging environment"
    echo "  production           Destroy production environment"
    echo "  all                  Destroy both environments"
    echo ""
    echo "Options:"
    echo "  --auto-approve       Skip confirmation prompts"
    echo ""
    echo "Examples:"
    echo "  $0 staging           # Destroy staging (with confirmation)"
    echo "  $0 production        # Destroy production (with confirmation)"
    echo "  $0 all               # Destroy both environments"
    echo "  $0 all --auto-approve    # Destroy all without prompts"
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

# Parse arguments
ENV=$1
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites

# Destroy based on argument
case $ENV in
    staging)
        destroy_environment "staging"
        ;;
    production)
        destroy_environment "production"
        ;;
    all)
        destroy_environment "staging"
        echo ""
        destroy_environment "production"
        echo ""
        cleanup_artifact_buckets
        echo ""
        
        # Ask about backend cleanup
        print_warning "Do you also want to delete the Terraform backend?"
        if [ "$AUTO_APPROVE" = false ]; then
            read -p "Delete backend? (yes/no): " delete_backend
            if [ "$delete_backend" = "yes" ]; then
                cleanup_terraform_backend
            fi
        fi
        ;;
    *)
        print_error "Invalid environment: $ENV"
        show_usage
        exit 1
        ;;
esac

print_header "Destruction Complete"
print_success "All destruction tasks completed"
echo ""
print_info "State backups saved in: $SCRIPT_DIR/backup-*-state-*.json"
echo ""
