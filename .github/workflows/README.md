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

## CD Pipeline (`cd.yml`) - Coming in Phase 5
The Continuous Deployment pipeline will handle infrastructure provisioning and application deployment to AWS Elastic Beanstalk.

### Planned Features
- Terraform infrastructure provisioning
- Application packaging and S3 upload
- Deployment to staging environment
- Automated E2E, performance, and security testing
- Manual approval gate for production
- Blue-green deployment with CNAME swap
- Rollback capabilities

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
