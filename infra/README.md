# Terraform Infrastructure for BP Calculator

This directory contains Terraform configuration for deploying the Blood Pressure Calculator application to AWS Elastic Beanstalk with separate staging and production environments.

## Directory Structure

```
infra/
├── backend.tf                    # S3 backend configuration
├── providers.tf                  # AWS provider configuration
├── variables.tf                  # Variable definitions
├── main.tf                       # Main infrastructure resources
├── outputs.tf                    # Output values
├── env/
│   ├── staging.backend.tfvars    # Staging backend config
│   ├── staging.tfvars            # Staging environment variables
│   ├── production.backend.tfvars # Production backend config
│   └── production.tfvars         # Production environment variables
└── README.md                     # This file
```

## Separate State Files Strategy

**Critical:** We use **separate Terraform state files** for staging and production to ensure:
- Staging and production infrastructures are completely independent
- Deploying to staging doesn't affect production resources
- Destroying staging doesn't touch production resources
- Each environment can be managed independently

### State File Locations:
- **Staging:** `s3://bp-terraform-state-431774613177/bp-calculator/staging/terraform.tfstate`
- **Production:** `s3://bp-terraform-state-431774613177/bp-calculator/production/terraform.tfstate`

## Prerequisites

1. **AWS CLI configured** with credentials
2. **Terraform installed** (>= 1.0)
3. **Backend resources created:**
   - S3 bucket: `bp-terraform-state-431774613177`
   - DynamoDB table: `bp-terraform-locks`

## Usage

### Initialize Terraform for Staging

```bash
cd infra
terraform init -backend-config="env/staging.backend.tfvars"
```

### Initialize Terraform for Production

```bash
cd infra
terraform init -backend-config="env/production.backend.tfvars" -reconfigure
```

**Note:** Use `-reconfigure` when switching between environments to update the backend configuration.

### Plan Deployment

#### Staging:
```bash
terraform plan -var-file="env/staging.tfvars" -out=staging.tfplan
```

#### Production:
```bash
terraform plan -var-file="env/production.tfvars" -out=production.tfplan
```

### Apply Deployment

#### Staging:
```bash
terraform apply staging.tfplan
```

#### Production:
```bash
terraform apply production.tfplan
```

### Destroy Environment

#### Staging:
```bash
terraform destroy -var-file="env/staging.tfvars"
```

#### Production:
```bash
terraform destroy -var-file="env/production.tfvars"
```

## Switching Between Environments

When working with multiple environments, you need to reinitialize Terraform with the correct backend configuration:

```bash
# Switch to staging
terraform init -backend-config="env/staging.backend.tfvars" -reconfigure

# Switch to production
terraform init -backend-config="env/production.backend.tfvars" -reconfigure
```

## Environment Configuration

### Staging
- Instance Type: t3.micro (free tier)
- Min Instances: 1
- Max Instances: 2
- Purpose: Testing and validation

### Production
- Instance Type: t3.micro (free tier)
- Min Instances: 1
- Max Instances: 4
- Purpose: Live application

## AWS Resources Created

Each environment creates:
- **Elastic Beanstalk Application**
- **Elastic Beanstalk Environment** (staging or production)
- **S3 Bucket** for application artifacts
- **IAM Roles** for EB service and EC2 instances
- **CloudWatch Log Groups** for application logs
- **CloudWatch Alarms** for monitoring

## Cost Considerations

- **t3.micro instances:** Free tier eligible (750 hours/month)
- **S3 storage:** ~$0.023/GB/month
- **CloudWatch Logs:** First 5GB free
- **Elastic Beanstalk:** No additional charge (only for resources used)

**Estimated Monthly Cost:** $0-5 (within free tier limits)

## State Locking

Terraform uses DynamoDB table `bp-terraform-locks` to prevent concurrent state modifications. This ensures:
- Multiple users/processes don't conflict
- State file integrity is maintained
- Concurrent applies are prevented

## Best Practices

1. **Always use separate state files** for staging and production
2. **Test changes in staging first** before applying to production
3. **Review plan output** carefully before applying
4. **Keep state files secure** (they're in private S3 bucket)
5. **Use workspaces carefully** (we're using separate state keys instead)
6. **Commit .tfvars files** but never commit .tfstate files
7. **Use version control** for all Terraform configurations

## Troubleshooting

### Error: Backend initialization failed
**Solution:** Run `terraform init -backend-config="env/{environment}.backend.tfvars" -reconfigure`

### Error: State lock timeout
**Solution:** Check DynamoDB table for stale locks, or wait for previous operation to complete

### Error: Cannot change backend configuration
**Solution:** Use `-reconfigure` flag when switching environments

### Verify current state location
```bash
terraform show | head -5
```

## Security Notes

- State files are encrypted at rest (AES256)
- State files are versioned in S3
- Access controlled via IAM policies
- No sensitive data in variable files
- Backend credentials stored in AWS CLI config

## Next Steps

After infrastructure is deployed:
1. Application will be deployed via CI/CD pipeline
2. Blue-green deployment via CNAME swap
3. Monitoring via CloudWatch
4. Logs streamed to CloudWatch Logs
