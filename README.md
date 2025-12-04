# Blood Pressure Calculator - CI/CD Project

[![.NET](https://img.shields.io/badge/.NET-9.0-512BD4)](https://dotnet.microsoft.com/)
[![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-FF9900)](https://aws.amazon.com/elasticbeanstalk/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-844FBA)](https://www.terraform.io/)

**TU Dublin MSc in DevOps** - Continuous Software Deployment (CSD) CA1 Project

## 📋 Project Overview

Blood Pressure Category Calculator web application with complete CI/CD pipeline including comprehensive testing, Infrastructure as Code, multi-environment deployment, and blue-green deployment strategy.

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
├── infra/                 # Terraform infrastructure
├── .github/workflows/     # CI/CD pipelines
├── deploy.sh              # Deployment automation
├── destroy.sh             # Teardown automation
├── PHASE0_NOTES.md       # Phase 0 completion notes
├── COST_MANAGEMENT.md    # Cost analysis
└── SCRIPTS_README.md     # Scripts documentation
```

---

## 📊 Phase Progress

- ✅ **Phase 0:** Foundation Setup (Complete)
- ⬜ **Phase 1:** Application Logic & Testing
- ⬜ **Phase 2:** Telemetry & Observability
- ⬜ **Phase 3:** Terraform Infrastructure
- ⬜ **Phase 4:** CI Pipeline
- ⬜ **Phase 5:** CD Pipeline
- ⬜ **Phase 6:** New Feature
- ⬜ **Phase 7:** Evidence Collection
- ⬜ **Phase 8:** Report & Video

---

## 📚 Documentation

- [Execution Plan](../../EXECUTION_PLAN.md) - Complete project plan
- [Phase 0 Notes](PHASE0_NOTES.md) - Foundation setup
- [Infrastructure Docs](infra/README.md) - Terraform setup
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

**Status:** Phase 0 Complete ✅ | Ready for Phase 1 🚀
