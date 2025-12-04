# AWS Cost Management and Cleanup Plan

## 📊 AWS Free Tier Limits (First 12 Months)

### Compute (EC2)
- **750 hours/month** of t2.micro or t3.micro Linux instances
- **Note:** We're using t3.micro in eu-west-1 (free tier eligible)
- **Our Usage:** 2 environments × 24 hours/day = 1,440 hours/month
- **⚠️ WARNING:** This **EXCEEDS** free tier by ~690 hours/month

### Storage (S3)
- **5 GB** standard storage
- **20,000 GET requests**
- **2,000 PUT requests**
- **Our Usage:** <100 MB (well within limits ✅)

### Database (DynamoDB)
- **25 GB** storage
- **25 provisioned write capacity units**
- **25 provisioned read capacity units**
- **Our Usage:** <1 MB, PAY_PER_REQUEST mode (minimal cost ✅)

### CloudWatch
- **10 custom metrics**
- **10 alarms**
- **5 GB log ingestion**
- **Our Usage:** ~5 metrics, 8 alarms, <1 GB logs (within limits ✅)

### Elastic Beanstalk
- **No additional charge** (only pay for underlying resources)

---

## 💰 Estimated Monthly Costs

### Scenario 1: Both Environments Running 24/7
| Resource | Quantity | Rate | Monthly Cost |
|----------|----------|------|--------------|
| t3.micro instances | 2 (1 staging + 1 prod) | $0.0104/hour | $15.12 |
| S3 storage (artifacts) | ~1 GB | $0.023/GB | $0.02 |
| S3 requests | ~1,000 | Minimal | $0.01 |
| DynamoDB (state locks) | PAY_PER_REQUEST | ~100 requests | $0.01 |
| CloudWatch Logs | <1 GB | Free tier | $0.00 |
| CloudWatch Alarms | 8 alarms | Free tier | $0.00 |
| **TOTAL** | | | **~$15.16/month** |

### Scenario 2: Only Production Running (Recommended for Cost Savings)
| Resource | Quantity | Rate | Monthly Cost |
|----------|----------|------|--------------|
| t3.micro instance (prod) | 1 | $0.0104/hour | $7.56 |
| Other resources | Same as above | Minimal | $0.04 |
| **TOTAL** | | | **~$7.60/month** |

### Scenario 3: Run Staging Only During Testing (Best Practice)
| Resource | Monthly Cost |
|----------|--------------|
| Production (24/7) | $7.56 |
| Staging (40 hours/month for testing) | $0.42 |
| Other resources | $0.04 |
| **TOTAL** | **~$8.02/month** |

---

## 💡 Cost Optimization Strategies

### 1. Destroy Staging When Not Testing
```bash
cd infra
terraform init -backend-config="env/staging.backend.tfvars" -reconfigure
terraform destroy -var-file="env/staging.tfvars"
```
**Savings:** ~$7.56/month

### 2. Use Scheduled Scaling (Advanced)
- Scale staging to 0 instances during off-hours
- Requires additional configuration
- **Savings:** Variable based on schedule

### 3. Destroy Both Environments After Project Submission
```bash
./destroy.sh all
```
**Savings:** $15.16/month (100% cost elimination)

### 4. Monitor with AWS Budgets
- Set up budget alerts at $5, $10, $15 thresholds
- Receive email notifications before costs escalate

---

## 🧹 Cleanup Plan

### Option 1: Automated Cleanup Script (Recommended)
We'll create `destroy.sh` script in Phase 0.5 that will:
1. Destroy production environment
2. Destroy staging environment
3. Empty and delete S3 artifact buckets
4. Optionally delete Terraform backend resources

**Usage:**
```bash
./destroy.sh all --auto-approve
```

### Option 2: Manual Cleanup (Step-by-Step)

#### Step 1: Destroy Production Environment
```bash
cd infra
terraform init -backend-config="env/production.backend.tfvars" -reconfigure
terraform destroy -var-file="env/production.tfvars"
```

#### Step 2: Destroy Staging Environment
```bash
terraform init -backend-config="env/staging.backend.tfvars" -reconfigure
terraform destroy -var-file="env/staging.tfvars"
```

#### Step 3: Delete Artifact Buckets
```bash
# List buckets
aws s3 ls | grep bp-calculator

# Empty and delete each bucket
aws s3 rm s3://bp-calculator-eb-artifacts-staging --recursive
aws s3 rb s3://bp-calculator-eb-artifacts-staging

aws s3 rm s3://bp-calculator-eb-artifacts-production --recursive
aws s3 rb s3://bp-calculator-eb-artifacts-production
```

#### Step 4: Delete Terraform Backend (Optional - Only After Complete Cleanup)
```bash
# Delete state files
aws s3 rm s3://bp-terraform-state-431774613177 --recursive

# Delete S3 bucket
aws s3 rb s3://bp-terraform-state-431774613177

# Delete DynamoDB table
aws dynamodb delete-table --table-name bp-terraform-locks --region eu-west-1
```

⚠️ **WARNING:** Only delete backend resources after destroying ALL environments!

---

## 📅 Recommended Cleanup Timeline

### During Development (Dec 4-9, 2025)
- ✅ Keep production running for testing
- ✅ Destroy staging after each test session
- ✅ Monitor costs daily

### After Project Submission (Dec 10+, 2025)
- ⏰ **December 11:** Destroy staging environment
- ⏰ **December 12:** Destroy production environment
- ⏰ **December 13:** Delete all artifact buckets
- ⏰ **December 14:** (Optional) Delete Terraform backend

### Cost During Project Timeline (Dec 4-10)
- **7 days × $15.16/day = ~$3.52 total**
- If staging destroyed nightly: **7 days × $8.02/day = ~$1.87 total**

---

## 🚨 Cost Alerts Setup

### Set Up AWS Budget Alert (Recommended)
```bash
aws budgets create-budget \
  --account-id 431774613177 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

### Example Budget Configuration
```json
{
  "BudgetName": "BP-Calculator-Monthly-Budget",
  "BudgetLimit": {
    "Amount": "20",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
```

### Manual Monitoring
- Check AWS Cost Explorer daily: https://console.aws.amazon.com/cost-management/
- Review billing dashboard: https://console.aws.amazon.com/billing/

---

## 📋 Pre-Submission Checklist

Before submitting the project on December 10:
- [ ] Video demo recorded
- [ ] Report completed
- [ ] All evidence collected
- [ ] GitHub repository finalized
- [ ] Production environment tested and verified

After submission:
- [ ] Destroy staging environment (saves $7.56/month)
- [ ] Keep production for 1-2 days for any questions
- [ ] Destroy production environment
- [ ] Delete all artifact buckets
- [ ] (Optional) Delete Terraform backend

---

## 💾 Backup Before Cleanup

Before destroying environments, backup important data:
1. **Screenshots:** All evidence from Phase 7
2. **CloudWatch Logs:** Export if needed for reference
3. **Application Artifacts:** Download from S3 if needed
4. **Terraform State:** Already backed up in S3 with versioning

---

## 🔄 Re-Deployment After Cleanup

If you need to re-deploy after cleanup:
```bash
cd infra
terraform init -backend-config="env/production.backend.tfvars"
terraform apply -var-file="env/production.tfvars"
```

The Terraform state files remain in S3, so you can recreate environments anytime.

---

## Summary

- **Development Cost:** ~$3.52 for 7 days (both environments)
- **Optimized Cost:** ~$1.87 for 7 days (destroy staging nightly)
- **Post-Submission:** $0 (destroy all resources)
- **Cleanup Time:** ~10 minutes using automated scripts

**Recommendation:** Use the optimized approach and destroy all resources immediately after project submission to minimize costs.
