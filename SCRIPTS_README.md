# Deployment Automation Scripts

This directory contains automated scripts for deploying and destroying the BP Calculator infrastructure on AWS.

## 📋 Available Scripts

### 1. `deploy.sh` - Deployment Script
Automates the deployment of infrastructure using Terraform.

**Features:**
- ✅ Prerequisites checking (Terraform, AWS CLI, credentials)
- ✅ Terraform initialization with correct backend
- ✅ Configuration validation
- ✅ Interactive deployment approval
- ✅ Separate staging and production deployments
- ✅ Colored output for better readability

**Usage:**
```bash
./deploy.sh [staging|production|all]
```

**Examples:**
```bash
# Deploy staging environment
./deploy.sh staging

# Deploy production environment
./deploy.sh production

# Deploy both environments
./deploy.sh all
```

### 2. `destroy.sh` - Destruction Script
Automates the destruction of infrastructure with safety confirmations.

**Features:**
- ✅ Prerequisites checking
- ✅ Multiple confirmation prompts for safety
- ✅ Terraform state backup before destruction
- ✅ Artifact bucket cleanup
- ✅ Optional Terraform backend cleanup
- ✅ Auto-approve mode for automation

**Usage:**
```bash
./destroy.sh [staging|production|all] [--auto-approve]
```

**Examples:**
```bash
# Destroy staging (with confirmations)
./destroy.sh staging

# Destroy production (with confirmations)
./destroy.sh production

# Destroy everything with confirmations
./destroy.sh all

# Destroy everything without prompts (USE WITH CAUTION!)
./destroy.sh all --auto-approve
```

## 🔐 Safety Features

### Deploy Script Safety:
- Validates Terraform configuration before applying
- Shows plan output before deployment
- Requires explicit "yes" confirmation
- Displays deployment outputs after completion

### Destroy Script Safety:
- **Multiple confirmation prompts**
- Requires typing specific confirmation text (e.g., "DELETE-staging")
- Backs up Terraform state before destruction
- Lists all resources to be destroyed
- Separates environment destruction from backend cleanup

## 🚀 Typical Workflows

### First-Time Deployment
```bash
# 1. Deploy staging for testing
./deploy.sh staging

# 2. Test the staging environment
# (Visit staging URL, run tests)

# 3. Deploy production
./deploy.sh production
```

### Daily Development Workflow
```bash
# Morning: Deploy staging for testing
./deploy.sh staging

# ... test and develop ...

# Evening: Destroy staging to save costs
./destroy.sh staging
```

### Post-Submission Cleanup
```bash
# Destroy all environments and cleanup everything
./destroy.sh all

# When prompted, confirm backend deletion to remove all traces
```

## 📊 What Gets Deployed

When you run `deploy.sh`, it creates:
- **Elastic Beanstalk Application**
- **Elastic Beanstalk Environment** (staging or production)
- **S3 Bucket** for application artifacts
- **IAM Roles** (service role + instance profile)
- **CloudWatch Log Groups**
- **CloudWatch Alarms** (if enabled)
- **Security Groups**
- **Load Balancer** (Application Load Balancer)
- **Auto Scaling Group**

## 🗑️ What Gets Destroyed

When you run `destroy.sh`, it removes:
- All infrastructure resources listed above
- S3 artifact buckets (with confirmation)
- Optionally: Terraform backend resources (S3 bucket + DynamoDB table)

**Note:** Terraform state files are backed up before destruction to `backup-{env}-state-{timestamp}.json`

## ⚠️ Important Notes

### 1. Environment Isolation
Each environment (staging/production) has:
- Separate Terraform state file in S3
- Independent infrastructure resources
- No cross-environment dependencies

### 2. Cost Management
- **Staging:** Destroy when not testing (~$7.56/month savings)
- **Production:** Keep running only when needed
- **Both:** ~$15.16/month if running 24/7

### 3. State Management
- State files stored in S3: `bp-terraform-state-431774613177`
- State locking via DynamoDB: `bp-terraform-locks`
- Automatic state backup before destruction

### 4. Backend Cleanup
⚠️ **ONLY** delete the Terraform backend after destroying ALL environments!
- Deleting backend = losing all state history
- Cannot easily redeploy without recreating backend
- Recommended only for complete project cleanup

## 🔧 Troubleshooting

### Error: "Terraform not found"
**Solution:** Install Terraform
```bash
brew install terraform  # macOS
```

### Error: "AWS credentials not configured"
**Solution:** Configure AWS CLI
```bash
aws configure
```

### Error: "Backend initialization failed"
**Solution:** Verify backend resources exist
```bash
aws s3 ls s3://bp-terraform-state-431774613177
aws dynamodb describe-table --table-name bp-terraform-locks --region eu-west-1
```

### Error: "Cannot switch between environments"
**Solution:** Use -reconfigure flag (automatically done by scripts)
```bash
terraform init -backend-config="env/staging.backend.tfvars" -reconfigure
```

### Destroy hangs or times out
**Possible causes:**
- Resources still in use
- Elastic Beanstalk environment stuck in transitioning state
- S3 buckets not empty

**Solutions:**
1. Check AWS Console for resource status
2. Manually terminate stuck resources
3. Empty S3 buckets manually if needed
4. Re-run destroy script

## 📝 Script Output

### Deploy Script Output:
```
========================================
Deploying staging Environment
========================================
ℹ️  Checking prerequisites...
✅ All prerequisites met
ℹ️  Initializing Terraform for staging...
ℹ️  Validating Terraform configuration...
ℹ️  Planning deployment...
⚠️  Ready to apply changes to staging environment
Do you want to proceed? (yes/no): yes
ℹ️  Applying deployment...
✅ staging environment deployed successfully!
```

### Destroy Script Output:
```
========================================
Destroying staging Environment
========================================
⚠️  THIS WILL PERMANENTLY DELETE ALL RESOURCES IN staging ENVIRONMENT!
Type 'DELETE-staging' to confirm destruction: DELETE-staging
ℹ️  Backing up Terraform state...
ℹ️  Destroying infrastructure...
✅ staging environment destroyed successfully!
```

## 🎯 Best Practices

1. **Always test in staging first** before deploying to production
2. **Destroy staging nightly** during development to save costs
3. **Keep production running** only when needed for demos/testing
4. **Back up important data** before running destroy
5. **Review plan output** before confirming deployments
6. **Monitor AWS costs** daily during project
7. **Clean up completely** after project submission

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- Project Cost Management: `COST_MANAGEMENT.md`
- Infrastructure Documentation: `infra/README.md`

## 🆘 Need Help?

If you encounter issues:
1. Check the troubleshooting section above
2. Review AWS Console for resource status
3. Check CloudWatch logs for errors
4. Verify AWS credentials and permissions
5. Ensure all prerequisites are installed

---

**Remember:** These scripts control your AWS infrastructure. Always double-check the environment you're deploying/destroying!
