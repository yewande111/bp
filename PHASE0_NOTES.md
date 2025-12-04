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
- Phase 0.2: Configure AWS credentials for CI/CD
- Phase 0.3: Setup Terraform backend (S3 + DynamoDB)
- Phase 0.4: Review AWS costs and setup cleanup plan
- Phase 0.5: Create deployment automation scripts

---
*End of Phase 0.1*
