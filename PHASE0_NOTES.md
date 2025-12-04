# Phase 0 - Foundation Setup Notes

## Phase 0.1: Fork and Inspect Repository ✅

**Date:** December 4, 2025  
**Status:** COMPLETE

### Actions Completed:
1. ✅ Forked https://github.com/gclynch/bp to https://github.com/yewande111/bp
2. ✅ Cloned repository locally to `/Users/user/Documents/bp/bp-app`
3. ✅ Opened project in VS Code
4. ✅ Verified .NET SDK installed (version 9.0.305)
5. ✅ Successfully restored dependencies with `dotnet restore`
6. ✅ Successfully built project with `dotnet build`
7. ✅ Confirmed application runs with `dotnet run`
8. ✅ Verified UI loads at http://localhost:5000

### Repository Structure:
```
bp-app/
├── BPCalculator/              # Main ASP.NET Core application
│   ├── Pages/                 # Razor Pages
│   ├── wwwroot/               # Static files
│   ├── BloodPressure.cs       # Core BP logic (incomplete)
│   ├── Startup.cs             # App configuration
│   └── BPCalculator.csproj    # Project file
├── BPCalculator.sln           # Solution file
├── .gitignore                 # Git ignore rules
└── README.md                  # Project README
```

### Key Observations:
- The application is a Razor Pages ASP.NET Core web app
- Blood pressure classification logic in `BloodPressure.cs` is incomplete
- No tests exist yet (will be added in Phase 1)
- No CI/CD pipelines configured yet (will be added in Phase 4-5)
- Application currently runs on port 5000

### Next Steps:
- Phase 0.2: Configure AWS credentials for CI/CD ✅
- Phase 0.3: Setup Terraform backend (S3 + DynamoDB) ✅
- Phase 0.4: Review AWS costs and setup cleanup plan
- Phase 0.5: Create deployment automation scripts

---
*End of Phase 0.1*

## Phase 0.2: Configure AWS Credentials for CI/CD ✅

**Date:** December 4, 2025  
**Status:** COMPLETE

### Actions Completed:
1. ✅ Created IAM user: `bp-calculator-cicd`
2. ✅ Attached required permissions:
   - AWSElasticBeanstalkFullAccess
   - AmazonS3FullAccess
   - CloudWatchLogsFullAccess
   - CloudWatchFullAccess
   - IAMFullAccess
3. ✅ Generated access keys for programmatic access
4. ✅ Stored credentials in GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` = `eu-west-1`

### AWS Account Details:
- **Account ID:** 431774613177
- **Region:** eu-west-1 (Ireland)
- **ARN:** arn:aws:iam::431774613177:root

### Security Notes:
- Access keys stored securely in GitHub repository secrets
- Keys never committed to repository
- IAM user has minimum required permissions for CI/CD

---
*End of Phase 0.2*

## Phase 0.3: Setup Terraform Backend ✅

**Date:** December 4, 2025  
**Status:** COMPLETE

### Actions Completed:
1. ✅ Created S3 bucket for Terraform state:
   - **Bucket Name:** `bp-terraform-state-431774613177`
   - **Region:** eu-west-1
   - **Versioning:** Enabled
   - **Encryption:** AES256 (enabled)

2. ✅ Created DynamoDB table for state locking:
   - **Table Name:** `bp-terraform-locks`
   - **Primary Key:** LockID (String)
   - **Billing Mode:** PAY_PER_REQUEST (on-demand)
   - **Status:** ACTIVE
   - **ARN:** arn:aws:dynamodb:eu-west-1:431774613177:table/bp-terraform-locks

### Terraform Backend Configuration:

**Important:** We use **separate state files** for staging and production environments to prevent them from destroying each other's infrastructure.

#### Staging Environment:
```hcl
terraform {
  backend "s3" {
    bucket         = "bp-terraform-state-431774613177"
    key            = "bp-calculator/staging/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "bp-terraform-locks"
    encrypt        = true
  }
}
```

#### Production Environment:
```hcl
terraform {
  backend "s3" {
    bucket         = "bp-terraform-state-431774613177"
    key            = "bp-calculator/production/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "bp-terraform-locks"
    encrypt        = true
  }
}
```

### Multi-Environment Strategy:
- **Separate State Keys:** 
  - Staging: `bp-calculator/staging/terraform.tfstate`
  - Production: `bp-calculator/production/terraform.tfstate`
- **Shared Backend Resources:** Both environments use the same S3 bucket and DynamoDB table
- **State Isolation:** Each environment maintains its own infrastructure without conflicts
- **Deployment Independence:** Can deploy/destroy staging without affecting production

### Why These Resources?
- **S3 Bucket:** Stores Terraform state files (versioned for rollback capability)
- **Versioning:** Protects against accidental state file deletion/corruption
- **Encryption:** Ensures state files are encrypted at rest
- **DynamoDB Table:** Provides state locking to prevent concurrent modifications (shared across environments)
- **PAY_PER_REQUEST:** Cost-effective for low-frequency operations

### Cost Estimation:
- **S3 Storage:** ~$0.023/GB/month (state files are typically <1MB each)
- **DynamoDB:** Pay per request (~$0.0000125 per read/write)
- **Expected Monthly Cost:** <$0.10 for Terraform backend (both environments)

### Terraform Directory Structure Created:
```
infra/
├── backend.tf                    # S3 backend configuration
├── env/
│   ├── staging.backend.tfvars    # Staging state key
│   ├── staging.tfvars            # Staging variables
│   ├── production.backend.tfvars # Production state key
│   └── production.tfvars         # Production variables
└── README.md                     # Infrastructure documentation
```

### How to Use Multiple Environments:

**Initialize for Staging:**
```bash
cd infra
terraform init -backend-config="env/staging.backend.tfvars"
terraform plan -var-file="env/staging.tfvars"
```

**Initialize for Production:**
```bash
cd infra
terraform init -backend-config="env/production.backend.tfvars" -reconfigure
terraform plan -var-file="env/production.tfvars"
```

**Note:** The `-reconfigure` flag is needed when switching between environments.

---
*End of Phase 0.3*
