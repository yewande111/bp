# Blood Pressure Calculator - CI/CD Project

[![.NET](https://img.shields.io/badge/.NET-9.0-512BD4)](https://dotnet.microsoft.com/)
[![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-FF9900)](https://aws.amazon.com/elasticbeanstalk/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-844FBA)](https://www.terraform.io/)

**TU Dublin MSc in DevOps** - Continuous Software Deployment (CSD) CA1 Project

## 📋 Project Overview

Blood Pressure Category Calculator web application with complete CI/CD pipeline including comprehensive testing, Infrastructure as Code, multi-environment deployment, and blue-green deployment strategy.

## ✨ Features Implemented

### Blood Pressure Classification
- ✅ Accurate BP categorization (Low, Ideal, Pre-High, High)
- ✅ Range validation (Systolic: 70-190, Diastolic: 40-100)
- ✅ Input validation with error handling

### Testing Suite
- ✅ 27 comprehensive unit tests (xUnit)
- ✅ 28 BDD scenarios (SpecFlow/Gherkin)
- ✅ 100% code coverage on business logic
- ✅ Boundary value testing & edge cases

### Observability
- ✅ AWS CloudWatch integration
- ✅ Structured logging with searchable fields
- ✅ Exception tracking with stack traces
- ✅ Multi-level logging (Info/Warning/Error)

### Infrastructure
- ✅ Terraform IaC with 20+ AWS resources (VPC, subnets, security groups, IAM, S3, Elastic Beanstalk)
- ✅ Terraform backend with S3 state storage
- ✅ DynamoDB state locking
- ✅ Multi-environment support (staging/production)
- ✅ Automated deployment scripts

### CI/CD Pipeline
- ✅ GitHub Actions CI workflow (Phase 4)
  - Automated build and test (55 tests)
  - Security scanning (OWASP Dependency Check)
  - Code quality checks (dotnet format)
  - Artifact generation (test results, coverage, security reports)
- ✅ GitHub Actions CD workflow (Phase 5)
  - Terraform infrastructure provisioning
  - Multi-environment deployment (staging/production)
  - Automated smoke and performance tests
  - Manual approval gate for production
  - Health monitoring and rollback capabilities

---

## 🚀 Quick Start

### Local Development

1. **Clone and run:**
   ```bash
   git clone https://github.com/yewande111/bp.git
   cd bp
   dotnet run --project BPCalculator/BPCalculator.csproj
   ```

2. **Access:** http://localhost:5000

### Deployment

```bash
./deploy.sh staging      # Deploy staging
./deploy.sh production   # Deploy production
./destroy.sh all         # Cleanup everything
```

---

## 📁 Project Structure

```
bp-app/
├── BPCalculator/          # ASP.NET Core application
│   ├── Pages/            # Razor Pages (Index with logging)
│   ├── BloodPressure.cs  # BP classification logic
│   └── Program.cs        # CloudWatch logging config
├── BPCalculator.Tests/   # Test suite (55 tests)
│   ├── BloodPressureTests.cs          # 27 unit tests
│   ├── Features/                       # BDD scenarios
│   └── StepDefinitions/               # SpecFlow steps
├── infra/                 # Terraform infrastructure
├── .github/workflows/     # CI/CD pipelines
│   ├── ci.yml            # CI Pipeline (Phase 4)
│   └── README.md         # Workflows documentation
├── deploy.sh              # Deployment automation
├── destroy.sh             # Teardown automation
├── PHASE0_NOTES.md       # Phase 0 completion notes
├── PHASE1_NOTES.md       # Phase 1 completion notes
├── PHASE2_NOTES.md       # Phase 2 completion notes
├── PHASE3_NOTES.md       # Phase 3 completion notes (Terraform)
├── PHASE4_NOTES.md       # Phase 4 completion notes (CI Pipeline)
├── PHASE5_NOTES.md       # Phase 5 completion notes (CD Pipeline)
├── COST_MANAGEMENT.md    # Cost analysis
└── SCRIPTS_README.md     # Scripts documentation
```

---

## 📊 Phase Progress

- ✅ **Phase 0:** Foundation Setup (Complete)
  - Repository forked, AWS configured, Terraform backend, deployment scripts
- ✅ **Phase 1:** Application Logic & Testing (Complete)
  - BP classification logic, 27 unit tests, 28 BDD tests, 100% coverage
- ✅ **Phase 2:** Telemetry & Observability (Complete)
  - CloudWatch logging, structured logging, exception tracking
- ✅ **Phase 3:** Terraform Infrastructure (Complete)
  - Complete IaC: VPC, subnets, security groups, IAM, S3, Elastic Beanstalk, CloudWatch alarms
- ✅ **Phase 4:** CI Pipeline (Complete)
  - GitHub Actions: build, test, security scan, code quality checks
- ✅ **Phase 5:** CD Pipeline (Complete)
  - Terraform provisioning, multi-environment deployment, smoke tests, manual approval
- ⬜ **Phase 6:** New Feature
- ⬜ **Phase 7:** Evidence Collection
- ⬜ **Phase 8:** Report & Video

---

## 📚 Documentation

- [Execution Plan](../../EXECUTION_PLAN.md) - Complete project plan
- [Phase 0 Notes](PHASE0_NOTES.md) - Foundation setup (AWS, Terraform, Scripts)
- [Phase 1 Notes](PHASE1_NOTES.md) - Testing & BP logic (55 tests, 100% coverage)
- [Phase 2 Notes](PHASE2_NOTES.md) - CloudWatch logging & telemetry
- [Phase 3 Notes](PHASE3_NOTES.md) - Terraform infrastructure (20+ AWS resources)
- [Phase 4 Notes](PHASE4_NOTES.md) - GitHub Actions CI Pipeline
- [Phase 5 Notes](PHASE5_NOTES.md) - GitHub Actions CD Pipeline (deployment)
- [Infrastructure Docs](infra/README.md) - Terraform setup
- [Workflows Guide](.github/workflows/README.md) - CI/CD pipelines
- [Scripts Guide](SCRIPTS_README.md) - Deployment automation
- [Cost Management](COST_MANAGEMENT.md) - Cost analysis & cleanup

---

## 🎓 Academic Context

**Course:** Continuous Software Deployment  
**Institution:** TU Dublin, Tallaght Campus  
**Program:** MSc in DevOps  
**Due Date:** December 10, 2025  
**Author:** Omolara Yewande (@yewande111)

---

---

## 🎯 Current Status

**Phases Complete:** 6/8 (75%)  
**Tests:** 55/55 Passing (100%)  
**Coverage:** 100% on BP Logic  
**CI Pipeline:** ✅ Running on GitHub Actions  
**CD Pipeline:** ✅ Configured (ready for AWS deployment)  
**Last Update:** December 4, 2025

---

**Status:** Phases 0-5 Complete ✅ | Ready for Phase 6 (New Feature) 🚀
