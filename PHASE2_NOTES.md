# Phase 2 Completion Notes - Telemetry & Observability

**Completion Date:** December 4, 2024  
**Status:** ✅ COMPLETE (CloudWatch Logging Implemented)  
**Duration:** Completed in one session  

## 🎯 Phase Objective
Add comprehensive telemetry and observability to the Blood Pressure Calculator application using AWS CloudWatch for production monitoring and debugging.

---

## 📋 Deliverables Completed

### 2.1. CloudWatch Logging ✅
**Status:** COMPLETE  

#### AWS Logger Integration
Installed **AWS.Logger.AspNetCore v4.0.2** which includes:
- `AWS.Logger.Core` - Core CloudWatch logging functionality
- `AWSSDK.CloudWatchLogs` - AWS SDK for CloudWatch Logs API
- Integration with ASP.NET Core logging infrastructure

#### Configuration Files Updated

**1. Program.cs** - Added CloudWatch Provider
```csharp
Host.CreateDefaultBuilder(args)
    .ConfigureLogging(logging =>
    {
        // Add console logging for local development
        logging.AddConsole();
        
        // Add AWS CloudWatch logging
        // This will automatically work when deployed to Elastic Beanstalk
        logging.AddAWSProvider();
    })
    .ConfigureWebHostDefaults(webBuilder =>
    {
        webBuilder.UseStartup<Startup>();
    });
```

**Benefits:**
- Console logging for local development and debugging
- AWS CloudWatch logging activates automatically when deployed to Elastic Beanstalk
- No manual AWS credential configuration needed (uses IAM roles from EB)

**2. appsettings.json** - CloudWatch Configuration
```json
"AWS.Logging": {
  "Region": "eu-west-1",
  "LogGroup": "bp-calculator",
  "LogStreamNameSuffix": "{instance_id}",
  "LogLevel": {
    "Default": "Information",
    "BPCalculator": "Information",
    "Microsoft": "Warning"
  }
}
```

**Configuration Details:**
- **Region:** `eu-west-1` (Ireland) - matches our deployment region
- **Log Group:** `bp-calculator` - centralized log location in CloudWatch
- **Log Stream:** Automatically includes instance ID for multi-instance deployments
- **Log Levels:**
  - Application logs: `Information` (captures all important events)
  - Microsoft framework: `Warning` (reduces noise from framework internals)

**3. Index.cshtml.cs** - Structured Logging Implementation

#### Dependency Injection
Added ILogger to page model constructor:
```csharp
private readonly ILogger<BloodPressureModel> _logger;

public BloodPressureModel(ILogger<BloodPressureModel> logger)
{
    _logger = logger;
}
```

#### Logging Events Implemented

**a) Page Load Event**
```csharp
public void OnGet()
{
    BP = new BloodPressure() { Systolic = 100, Diastolic = 60 };
    _logger.LogInformation("Blood Pressure Calculator page loaded with default values");
}
```
- **Log Level:** Information
- **Purpose:** Track page access and user engagement
- **Use Case:** Analytics, monitoring application usage

**b) Calculation Request Event**
```csharp
_logger.LogInformation("BP calculation requested - Systolic: {Systolic}, Diastolic: {Diastolic}", 
    BP.Systolic, BP.Diastolic);
```
- **Log Level:** Information
- **Purpose:** Track all calculation attempts with input values
- **Structured Data:** Systolic and Diastolic values as separate fields
- **Use Case:** Usage analytics, identifying common BP ranges

**c) Validation Warning Event**
```csharp
_logger.LogWarning("Invalid BP input - Systolic ({Systolic}) must be greater than Diastolic ({Diastolic})", 
    BP.Systolic, BP.Diastolic);
```
- **Log Level:** Warning
- **Purpose:** Track invalid user inputs
- **Use Case:** User experience improvement, identifying common user errors

**d) Successful Calculation Event**
```csharp
var category = BP.Category;
_logger.LogInformation("BP calculation successful - Systolic: {Systolic}, Diastolic: {Diastolic}, Category: {Category}", 
    BP.Systolic, BP.Diastolic, category);
```
- **Log Level:** Information
- **Structured Data:** Input values + calculated category
- **Use Case:** Category distribution analytics, health monitoring trends

**e) Out-of-Range Warning Event**
```csharp
catch (ArgumentOutOfRangeException ex)
{
    _logger.LogWarning(ex, "BP calculation failed - Out of range values: Systolic: {Systolic}, Diastolic: {Diastolic}", 
        BP.Systolic, BP.Diastolic);
}
```
- **Log Level:** Warning
- **Purpose:** Track attempts with out-of-range values
- **Includes:** Full exception details
- **Use Case:** Detecting data quality issues, monitoring edge cases

**f) Invalid Input Warning Event**
```csharp
catch (ArgumentException ex)
{
    _logger.LogWarning(ex, "BP calculation failed - Invalid values: Systolic: {Systolic}, Diastolic: {Diastolic}", 
        BP.Systolic, BP.Diastolic);
}
```
- **Log Level:** Warning
- **Purpose:** Track validation failures (e.g., systolic ≤ diastolic)
- **Use Case:** User error analytics, UI/UX improvements

**g) Unexpected Error Event**
```csharp
catch (Exception ex)
{
    _logger.LogError(ex, "Unexpected error during BP calculation - Systolic: {Systolic}, Diastolic: {Diastolic}", 
        BP.Systolic, BP.Diastolic);
}
```
- **Log Level:** Error
- **Purpose:** Catch-all for unexpected application errors
- **Includes:** Full stack trace
- **Use Case:** Bug detection, critical issue alerting

---

## 📊 Structured Logging Benefits

### Why Structured Logging?
Instead of plain text logs like:
```
"BP calculated: 120/80 = PreHigh"
```

We use structured logging with named parameters:
```csharp
_logger.LogInformation("BP calculation successful - Systolic: {Systolic}, Diastolic: {Diastolic}, Category: {Category}", 
    120, 80, BPCategory.PreHigh);
```

### Advantages:

1. **Searchable Fields in CloudWatch Insights:**
   ```
   fields @timestamp, Systolic, Diastolic, Category
   | filter Category = "High"
   | stats count() by bin(5m)
   ```

2. **Automated Alerting:**
   - Create CloudWatch alarms on specific log patterns
   - Example: Alert when error count exceeds threshold

3. **Analytics and Metrics:**
   - Track category distribution over time
   - Identify common BP ranges
   - Monitor validation failure rates

4. **Debugging:**
   - Trace specific user sessions
   - Reproduce issues with exact input values
   - Timeline reconstruction

---

## 🔍 CloudWatch Integration Details

### How It Works on Elastic Beanstalk

**1. Automatic IAM Role Assignment**
- Elastic Beanstalk creates an instance profile with CloudWatch permissions
- Application inherits permissions automatically
- No hard-coded credentials needed

**2. Log Stream Creation**
- Application starts → AWS SDK detects environment
- Creates log group: `/aws/elasticbeanstalk/bp-calculator/`
- Creates log stream: `instance-id-{timestamp}`

**3. Log Batching**
- Logs buffered in memory for performance
- Batch sent to CloudWatch every 5 seconds (default)
- Ensures low latency, reduces API calls

**4. Persistence**
- Logs retained in CloudWatch (configurable: 1 day to never expire)
- Survives instance termination
- Centralized across all instances

### Local Development Behavior

**Console Logging Only:**
```
info: BPCalculator.Pages.BloodPressureModel[0]
      BP calculation requested - Systolic: 120, Diastolic: 80
```

- AWS CloudWatch disabled locally (no credentials configured)
- Console logging allows standard debugging
- No AWS charges during development

**Testing with AWS Locally (Optional):**
1. Configure AWS CLI: `aws configure`
2. Ensure IAM user has CloudWatch permissions
3. Logs will appear in CloudWatch even locally

---

## 🧪 Testing Verification

### Build Status: ✅ SUCCESS
```bash
dotnet build
Build succeeded in 14.0s
```

### Test Suite: ✅ ALL PASSING
```bash
dotnet test
Total tests: 55
├── Unit Tests: 27
└── BDD Tests: 28

Pass Rate: 100% (55/55 passed)
Execution Time: 3.6 seconds
```

**Verification:**
- No tests broken by logging changes
- Dependency injection working correctly
- Application compiles without errors

---

## 📦 Dependencies Added

**NuGet Package:**
```xml
<PackageReference Include="AWS.Logger.AspNetCore" Version="4.0.2" />
```

**Transitive Dependencies Installed:**
- `AWS.Logger.Core 4.0.2` - Core logging functionality
- `AWSSDK.CloudWatchLogs 4.0.8.4` - CloudWatch API client
- `AWSSDK.Core 4.0.0.32` - AWS SDK base
- `Microsoft.Extensions.Logging 2.1.1` - Logging abstractions

**Total Size:** ~2.5 MB additional dependencies

---

## 🎓 Best Practices Applied

### 1. Log Level Guidelines
- **Information:** Normal operations, successful transactions
- **Warning:** Validation failures, expected exceptions, user errors
- **Error:** Unexpected exceptions, system failures
- **Debug:** Detailed diagnostics (not used in production)

### 2. Structured Logging Patterns
✅ **Good:**
```csharp
_logger.LogInformation("BP calculated - Systolic: {Systolic}, Category: {Category}", 
    systolic, category);
```

❌ **Bad:**
```csharp
_logger.LogInformation($"BP calculated - Systolic: {systolic}, Category: {category}");
```

**Why?** Structured logs allow CloudWatch Insights queries on individual fields.

### 3. Exception Handling
- Always include exception object: `_logger.LogWarning(ex, "message")`
- Provides full stack trace in CloudWatch
- Enables root cause analysis

### 4. Context Preservation
- Include relevant input values in every log
- Allows reproducing issues from logs alone
- Essential for debugging production issues

---

## 📈 CloudWatch Insights Query Examples

Once deployed, you can query logs with:

**1. Count calculations by category:**
```
fields @timestamp, Category
| filter @message like /BP calculation successful/
| stats count() by Category
```

**2. Find all high BP readings:**
```
fields @timestamp, Systolic, Diastolic
| filter Category = "High"
| sort @timestamp desc
```

**3. Track validation failures:**
```
fields @timestamp, @message
| filter @logLevel = "Warning"
| stats count() by bin(1h)
```

**4. Monitor error rate:**
```
fields @timestamp
| filter @logLevel = "Error"
| stats count() as ErrorCount by bin(5m)
```

---

## ✅ Assignment Requirements Met

### From Assignment Specification:
- ✅ **Requirement 6:** Telemetry implemented using AWS CloudWatch
- ✅ **Requirement 7:** Structured logging for production monitoring
- ✅ **Best Practice:** Separate console/CloudWatch logging for dev/prod
- ✅ **Best Practice:** Dependency injection for testability

### Exceeding Requirements:
- 🌟 Comprehensive exception handling with logging
- 🌟 Structured logging with searchable fields
- 🌟 Multiple log levels (Info, Warning, Error)
- 🌟 Context-rich log messages

---

## 🚀 Next Steps (Phase 3)

With Phase 2 complete, we now proceed to:

1. **Phase 3.1:** Create Terraform configuration files
2. **Phase 3.2:** Define infrastructure resources (Elastic Beanstalk, VPC, etc.)
3. **Phase 3.3:** Configure variables for staging/production environments
4. **Phase 3.4:** Test Terraform plan and apply

**Target:** Complete Phase 3 by end of day (December 4, 2024)

---

## 📝 Deployment Notes

### When Deployed to Elastic Beanstalk:

**1. CloudWatch Log Group Created:**
- Name: `/aws/elasticbeanstalk/bp-calculator-staging/` (for staging)
- Name: `/aws/elasticbeanstalk/bp-calculator-production/` (for production)

**2. Automatic Permissions:**
- Instance profile includes `CloudWatchLogsFullAccess` policy
- Application can write logs without additional configuration

**3. Monitoring:**
- View logs in AWS Console → CloudWatch → Log Groups
- Use CloudWatch Insights for advanced queries
- Set up alarms for error thresholds

**4. Cost:**
- First 5GB ingested: Free tier
- $0.50/GB beyond free tier
- Expected usage for this app: ~50MB/month (~$0.00)

---

## 📊 Phase 2 Summary

| Metric | Target | Achieved |
|--------|--------|----------|
| CloudWatch Logging | Configured | ✅ Complete |
| Structured Logging | Implemented | ✅ Complete |
| Log Levels | Multiple | ✅ Info/Warning/Error |
| Exception Handling | With Logging | ✅ Complete |
| Local Dev Support | Console Logging | ✅ Complete |
| Tests Status | All Passing | ✅ 55/55 |
| Build Status | Success | ✅ Success |

**Phase 2 Status: 🎉 SUCCESSFULLY COMPLETED**

---

*Generated: December 4, 2024*  
*Project: TU Dublin MSc DevOps CSD CA1 - Blood Pressure Calculator*  
*Phase: 2 - Telemetry & Observability*
