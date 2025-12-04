# GitHub Actions Workflows

This directory contains the CI/CD workflows for the BP Calculator application.

## CI Pipeline (`ci.yml`)

### Overview
The Continuous Integration pipeline runs on every push to `main` and on all pull requests. It performs build, test, security, and code quality checks.

### Triggers
- **Push to main:** Runs automatically when code is pushed to the main branch
- **Pull requests:** Runs automatically on all PRs targeting main
- **Manual dispatch:** Can be triggered manually from the Actions tab

### Jobs

#### 1. Build and Test
**Purpose:** Compile the application and run all tests with coverage reporting

**Steps:**
- Checkout code
- Setup .NET 9.0
- Restore NuGet dependencies
- Build solution in Release mode
- Run all tests (27 unit tests + 28 BDD tests = 55 total)
- Collect code coverage data
- Generate HTML coverage report
- Upload test results and coverage report as artifacts

**Success Criteria:** All 55 tests must pass

#### 2. Security Scan
**Purpose:** Identify security vulnerabilities in dependencies

**Steps:**
- Checkout code
- Setup .NET 9.0
- Restore dependencies
- Run `dotnet list package --vulnerable` to check for known vulnerabilities
- Download and run OWASP Dependency Check
- Generate security scan reports (HTML and JSON)
- Upload security scan results as artifacts

**Success Criteria:** No critical vulnerabilities found

#### 3. Code Quality
**Purpose:** Ensure code follows formatting standards

**Steps:**
- Checkout code
- Setup .NET 9.0
- Install dotnet-format tool
- Check code formatting with `dotnet format --verify-no-changes`
- Generate code quality summary

**Success Criteria:** Code passes formatting checks

#### 4. Pipeline Summary
**Purpose:** Aggregate results from all jobs

**Steps:**
- Generate summary table showing status of all jobs
- Display workflow metadata (branch, commit, author, trigger)
- Fail if any required job failed

**Success Criteria:** All jobs completed successfully

### Artifacts
The CI pipeline produces the following artifacts:
- **test-results:** Raw test results and coverage data
- **coverage-report:** HTML code coverage report
- **security-scan-results:** OWASP Dependency Check reports

### Viewing Results
1. Go to the **Actions** tab in the GitHub repository
2. Select the **CI Pipeline** workflow
3. Click on a specific workflow run to see details
4. View the **Summary** for an overview of all jobs
5. Download artifacts to review detailed reports

### Local Testing
Before pushing code, you can run the same checks locally:

```bash
# Build and test
cd bp-app
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release --collect:"XPlat Code Coverage"

# Check for vulnerabilities
dotnet list package --vulnerable --include-transitive

# Check code formatting
dotnet format --verify-no-changes
```

## CD Pipeline (`cd.yml`) - Phase 5 Complete ✅

The Continuous Deployment pipeline handles infrastructure provisioning and application deployment to AWS Elastic Beanstalk.

### Overview
Automatically deploys the application to staging and production environments with infrastructure provisioning, testing, and health checks.

### Triggers
- **Push to main:** Deploys to staging automatically (excludes markdown file changes)
- **Manual dispatch:** Deploy to specific environment (staging or production)

### Jobs

#### 1. Build and Package
**Purpose:** Build and package the application for deployment

**Steps:**
- Generate semantic version (1.0.{run_number})
- Build application in Release mode
- Run all tests
- Publish application with `dotnet publish`
- Create ZIP deployment package
- Upload artifact with 30-day retention

**Outputs:** version, artifact-name

#### 2. Deploy to Staging
**Purpose:** Provision infrastructure and deploy to staging environment

**Steps:**
- Configure AWS credentials
- Setup Terraform
- Initialize Terraform with S3 backend (staging state)
- Run `terraform plan` for staging environment
- Apply Terraform changes (creates/updates AWS resources)
- Get Terraform outputs (app name, environment name, S3 bucket)
- Download deployment package artifact
- Upload package to S3 version bucket
- Create Elastic Beanstalk application version
- Deploy to Elastic Beanstalk staging environment
- Wait for deployment to complete (environment updated)
- Get environment URL (CNAME)
- Run health check (10 attempts, 30s interval)
- Generate deployment summary

**Environment:** staging (no approval required)

#### 3. Test Staging Environment
**Purpose:** Validate staging deployment with automated tests

**Steps:**
- Get staging environment URL
- **Smoke Tests:**
  - Homepage returns 200 OK
  - Content contains "Blood Pressure"
  - Static resources (CSS) load successfully
- **Performance Check:**
  - Response time under 5 seconds
- Generate test summary

**Success Criteria:** All smoke tests pass, performance acceptable

#### 4. Deploy to Production
**Purpose:** Deploy to production after staging validation

**Steps:**
- Configure AWS credentials
- Setup Terraform
- Initialize Terraform with S3 backend (production state)
- Run `terraform plan` for production (2-4 instances)
- Apply Terraform changes
- Get Terraform outputs
- Download deployment package
- Upload to production S3 bucket
- Create/reuse Elastic Beanstalk application version
- Deploy to production environment
- Wait for deployment
- Get production URL
- Run production health check (15 attempts, 30s interval)
- Generate production deployment summary

**Environment:** production (requires manual approval in GitHub)

**Notes:**
- Only runs on `main` branch
- Requires all previous jobs to succeed
- Uses GitHub Environment protection rules

#### 5. Pipeline Complete
**Purpose:** Aggregate results and final summary

**Steps:**
- Generate comprehensive pipeline summary
- Display all job statuses
- Show version and commit information
- Determine overall success/failure

**Always Runs:** Uses `if: always()`

### Infrastructure Provisioned

**Staging Environment:**
- VPC with 2 public subnets (multi-AZ)
- Internet Gateway and route tables
- Security groups (HTTP/HTTPS)
- IAM roles and instance profile
- S3 bucket for application versions
- Elastic Beanstalk application
- Elastic Beanstalk environment (1 instance, t3.micro)
- CloudWatch log group and alarms

**Production Environment:**
- Same as staging, but with:
  - 2-4 instances (auto-scaling)
  - Enhanced monitoring
  - Separate state file and resources

### Deployment Flow

```
Push to main
     │
     ▼
Build & Package (3-5 min)
     │
     ├─ dotnet restore, build, test
     ├─ dotnet publish
     ├─ Create ZIP package
     └─ Upload artifact
     │
     ▼
Deploy Staging (5-10 min)
     │
     ├─ Terraform init
     ├─ Terraform plan/apply (provision AWS resources)
     ├─ Upload package to S3
     ├─ Create EB version
     ├─ Deploy to EB environment
     ├─ Wait for health checks
     └─ Verify deployment
     │
     ▼
Test Staging (1-2 min)
     │
     ├─ Smoke tests
     ├─ Performance check
     └─ Generate test report
     │
     ▼
Deploy Production (5-10 min)
     │
     ├─ Manual approval required ⏸️
     ├─ Terraform init (production state)
     ├─ Terraform plan/apply
     ├─ Deploy to production EB
     ├─ Wait for health checks
     └─ Verify production
     │
     ▼
Pipeline Complete
     │
     └─ Summary report
```

### Environment URLs

After deployment, access the application at:
- **Staging:** http://bp-calculator-staging.{region}.elasticbeanstalk.com
- **Production:** http://bp-calculator-production.{region}.elasticbeanstalk.com

(Actual URLs are displayed in the deployment summary)

### Manual Approval for Production

Production deployments require manual approval:
1. Go to Actions tab
2. Click on the running workflow
3. Click "Review deployments"
4. Select "production" environment
5. Click "Approve and deploy"

### Monitoring Deployments

**GitHub Actions:**
- View real-time logs in Actions tab
- Check deployment summaries
- Download artifacts

**AWS Console:**
- Elastic Beanstalk: View environment health and logs
- CloudWatch: View application logs and metrics
- S3: View deployed application versions

### Rollback Strategy

If a deployment fails or issues are detected:

**Option 1: Redeploy Previous Version**
```bash
# List available versions
aws elasticbeanstalk describe-application-versions \
  --application-name bp-calculator \
  --region eu-west-1

# Deploy previous version
aws elasticbeanstalk update-environment \
  --environment-name bp-calculator-production \
  --version-label v1.0.XX-PREVIOUS_SHA \
  --region eu-west-1
```

**Option 2: Trigger Manual Workflow**
- Go to Actions → CD Pipeline
- Click "Run workflow"
- Select environment
- Choose previous commit SHA

**Option 3: Emergency Rollback**
- Use AWS Console
- Elastic Beanstalk → Environments
- Click "Deploy a different version"
- Select previous working version

### Terraform State Management

**State Files:**
- Staging: `s3://bp-terraform-state-431774613177/staging/terraform.tfstate`
- Production: `s3://bp-terraform-state-431774613177/production/terraform.tfstate`

**State Locking:**
- DynamoDB table: `bp-terraform-locks`
- Prevents concurrent modifications
- Automatic lock acquisition/release

### Cost Optimization

**Staging:**
- Runs 24/7 for testing
- Single t3.micro instance (~$0.0104/hour)
- Estimated: ~$8-10/month

**Production:**
- 2-4 instances based on load
- Auto-scales during high traffic
- Estimated: ~$20-40/month

**S3 Storage:**
- Application versions retained
- ~$0.023/GB/month
- Estimated: ~$1-2/month

**Total Estimated Cost:** ~$30-55/month

### Troubleshooting

**Deployment fails at Terraform apply:**
- Check AWS credentials are valid
- Verify IAM permissions
- Review Terraform plan output
- Check resource quotas in AWS

**Health check fails:**
- Check Elastic Beanstalk logs
- Verify application starts correctly
- Check security group rules
- Review CloudWatch logs

**Version already exists error:**
- Pipeline handles this automatically
- Reuses existing version if found
- No action needed

**Timeout waiting for environment:**
- Increase wait time in workflow
- Check EB environment events
- May need larger instance type

## Best Practices

### Pull Request Workflow
1. Create feature branch from `main`
2. Make changes and commit
3. Push branch to GitHub
4. Create pull request
5. CI pipeline runs automatically
6. Review test results and security scan
7. Address any failures
8. Merge when all checks pass

### Monitoring CI Health
- Check the Actions tab regularly for failed workflows
- Review security scan reports for new vulnerabilities
- Monitor code coverage trends (aim for 100%)
- Keep dependencies up to date

### Troubleshooting

**Tests failing:**
- Check test results artifact for detailed error messages
- Run tests locally to reproduce: `dotnet test`
- Review recent code changes that might have broken tests

**Security scan warnings:**
- Review dependency-check-report artifact
- Update vulnerable packages: `dotnet add package <PackageName> --version <SafeVersion>`
- Add suppressions only for false positives

**Code formatting failures:**
- Run `dotnet format` locally to auto-fix formatting issues
- Commit the formatted code
- Push again to re-trigger CI

**Build failures:**
- Check for missing dependencies
- Verify .NET version compatibility
- Review build logs in the workflow run details

## Phase 4 Completion Checklist
- [x] Create `.github/workflows/` directory
- [x] Create `ci.yml` with all required jobs
- [x] Configure triggers (push, PR, manual)
- [x] Add build-and-test job with coverage
- [x] Add security-scan job with OWASP check
- [x] Add code-quality job with formatting check
- [x] Add pipeline-summary job
- [x] Configure artifact uploads
- [x] Create workflow documentation
- [ ] Test workflow by pushing to GitHub
- [ ] Verify all jobs pass
- [ ] Create PHASE4_NOTES.md documentation

## Related Documentation
- `../PHASE3_NOTES.md` - Infrastructure configuration details
- `../PHASE2_NOTES.md` - Telemetry and logging setup
- `../PHASE1_NOTES.md` - Testing strategy and coverage
- `../README.md` - Project overview and setup instructions
