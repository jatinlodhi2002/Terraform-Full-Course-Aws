# test.sh - S3 Remote Backend Setup Script

## Overview
This script **automates the setup of an S3 remote backend** for Terraform state file management. It creates and configures an S3 bucket with all necessary security and versioning settings for storing Terraform state files.

## How It Works

### 1. Creates a Unique S3 Bucket
```bash
BUCKET_NAME="terraform-state-$(date +%s)"  # Generates unique name with timestamp
aws s3 mb s3://$BUCKET_NAME --region $REGION  # Creates the bucket
```
- Uses timestamp to ensure bucket name uniqueness
- Creates bucket in `us-east-1` region

### 2. Enables Versioning
```bash
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled
```
- **Critical** for state locking and recovery
- Keeps history of all state file changes
- Allows rollback if something goes wrong
- **Required** for S3 native state locking

### 3. Enables Encryption
```bash
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'
```
- Uses AES256 server-side encryption
- Protects sensitive data in state files (passwords, keys, API tokens, etc.)
- Security best practice compliance

### 4. Prints Configuration Instructions
- Shows the bucket name and all enabled settings
- Provides the exact `backend.tf` configuration to copy
- Explains S3 native state locking (no DynamoDB needed)

## Why You Need This Script

### Problem Without Remote Backend:
When Terraform state files are stored locally:
- ❌ **Not shareable** with team members
- ❌ **Not backed up** automatically
- ❌ **Vulnerable to concurrent edits** (multiple people running terraform at once)
- ❌ **Can contain sensitive data** in plain text
- ❌ **Risk of loss** if your computer crashes
- ❌ **No locking mechanism** to prevent state corruption

### Solution With Remote Backend:
- ✅ **Team Collaboration**: Everyone shares the same state
- ✅ **State Locking**: Prevents 2+ people from modifying infrastructure simultaneously
- ✅ **Versioning**: Can recover from mistakes and track changes
- ✅ **Encryption**: Sensitive data is protected at rest
- ✅ **Backup**: S3's durability (99.999999999%)
- ✅ **Access Control**: IAM policies control who can access state

## S3 Native State Locking

This setup uses **S3 Native State Locking** (introduced in Terraform 1.10+):
- Uses S3 Conditional Writes (If-None-Match header)
- Creates temporary `.tflock` files in S3
- **No DynamoDB required** (previously needed for locking)
- Simpler setup and lower cost
- Stable in Terraform 1.11+

## Usage Workflow

### Step 1: Run the Script
```bash
chmod +x test.sh
./test.sh
```

### Step 2: Copy the Generated Configuration
The script outputs a `backend.tf` configuration:
```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-state-1736534400"  # Your unique bucket name
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

### Step 3: Add to Your Terraform Project
Create or update `backend.tf` in your Terraform project root with the generated configuration.

### Step 4: Initialize Terraform
```bash
terraform init
```
Terraform will:
- Detect the backend configuration
- Migrate local state to S3 (if exists)
- Configure state locking
- Set up encryption

### Step 5: Work Normally
```bash
terraform plan
terraform apply
```
All state operations now use the remote backend automatically.

## Benefits

| Feature | Local State | Remote State (S3) |
|---------|-------------|-------------------|
| **Team Collaboration** | ❌ Manual file sharing | ✅ Automatic sync |
| **State Locking** | ❌ None | ✅ Built-in |
| **Versioning** | ❌ Manual | ✅ Automatic |
| **Encryption** | ❌ Plain text | ✅ AES256 |
| **Backup** | ❌ Manual | ✅ S3 durability |
| **Access Control** | ❌ File permissions | ✅ IAM policies |
| **Concurrent Safety** | ❌ Risk of corruption | ✅ Locked operations |

## Security Features

1. **Encryption at Rest**: AES256 server-side encryption
2. **Versioning**: Track all changes, recover from accidents
3. **IAM Control**: Fine-grained access control
4. **Audit Trail**: CloudTrail logging of all S3 operations

## What This Script Saves You From

Without this script, you would need to manually:
1. Create S3 bucket with unique name
2. Enable versioning via AWS console or CLI
3. Configure encryption settings
4. Remember all the correct `backend.tf` parameters
5. Risk forgetting critical settings like versioning

This script ensures you don't miss any critical configuration steps and provides a consistent, repeatable setup process.

## Prerequisites

- AWS CLI installed and configured
- AWS credentials with S3 permissions:
  - `s3:CreateBucket`
  - `s3:PutBucketVersioning`
  - `s3:PutEncryptionConfiguration`
- Terraform 1.10+ (1.11+ recommended for stable S3 native locking)

## Notes

- Bucket names are globally unique across all AWS accounts
- The timestamp suffix ensures uniqueness
- Keep the bucket name safe - you'll need it for your `backend.tf`
- Don't delete the S3 bucket while actively using it for state storage
- Deleting the bucket will lose your state history (unless backed up elsewhere)
