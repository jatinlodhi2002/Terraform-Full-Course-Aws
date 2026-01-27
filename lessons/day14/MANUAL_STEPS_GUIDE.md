# Day 14: Static Website Hosting - Complete Guide

## 📚 Project Overview

This project demonstrates deploying a static website on AWS using **S3** for storage and **CloudFront** for global content delivery. We'll first understand the manual process on AWS Console, then automate it with Terraform.

### What You'll Build
- A responsive static website with HTML, CSS, and JavaScript
- S3 bucket configured for website hosting
- CloudFront CDN for fast global delivery with HTTPS
- Public access configuration for website files

---

## 🏗️ Architecture

```
┌─────────────────┐
│   User Browser  │
└────────┬────────┘
         │ HTTPS Request
         ↓
┌─────────────────────────────┐
│  CloudFront Distribution    │  ← Global CDN (Edge Locations)
│  - Caches content           │
│  - HTTPS enabled            │
│  - Fast delivery worldwide  │
└────────┬────────────────────┘
         │ Fetches from origin
         ↓
┌─────────────────────────────┐
│     S3 Bucket (Origin)      │
│  - Stores static files      │
│  - Public read access       │
├─────────────────────────────┤
│  📄 index.html              │
│  🎨 style.css               │
│  ⚡ script.js               │
└─────────────────────────────┘
```

### Key Benefits
✅ **Global Performance**: CloudFront delivers content from edge locations closest to users  
✅ **Scalability**: Automatically handles traffic spikes  
✅ **Security**: HTTPS encryption with CloudFront default certificate  
✅ **Cost-Effective**: Pay-as-you-go pricing, free tier available  
✅ **Reliability**: 99.99% durability with S3  

---

## 📋 Manual Steps on AWS Console

### Prerequisites
- Active AWS account
- Basic understanding of HTML/CSS/JS
- Website files ready (index.html, style.css, script.js)

---

### **STEP 1: Create an S3 Bucket**

1. **Navigate to S3 Console**
   - AWS Console → Services → S3
   - Click **"Create bucket"**

2. **Configure Bucket Settings**
   - **Bucket name**: Must be globally unique  
     Example: `my-static-website-demo-12345`
   - **AWS Region**: Choose closest to your users (e.g., `us-east-1`)
   - **Object Ownership**: ACLs disabled (recommended)

3. **Block Public Access Settings**
   - ⚠️ **IMPORTANT**: Uncheck **"Block all public access"**
   - Check the acknowledgment box
   - Note: We need public access for website hosting

4. **Other Settings** (Optional)
   - Bucket Versioning: Disabled (or Enable for version history)
   - Default encryption: Server-side encryption (SSE-S3)
   - Tags: Add tags if needed (e.g., `Project: StaticWebsite`)

5. **Create Bucket**
   - Click **"Create bucket"**
   - Wait for confirmation

---

### **STEP 2: Enable Static Website Hosting**

1. **Open Your Bucket**
   - Click on the bucket name from the S3 list

2. **Navigate to Properties**
   - Click **"Properties"** tab
   - Scroll to bottom

3. **Enable Static Website Hosting**
   - Find **"Static website hosting"** section
   - Click **"Edit"**
   - Select **"Enable"**

4. **Configure Website Settings**
   - **Hosting type**: Host a static website
   - **Index document**: `index.html`
   - **Error document**: `index.html` (optional, for SPAs)

5. **Save Changes**
   - Click **"Save changes"**
   - 📝 **Note the endpoint URL** displayed  
     Example: `http://my-static-website-demo-12345.s3-website-us-east-1.amazonaws.com`

---

### **STEP 3: Upload Website Files**

1. **Navigate to Objects Tab**
   - Click **"Objects"** tab
   - Click **"Upload"**

2. **Add Files**
   - Click **"Add files"** button
   - Select your website files:
     - `index.html` (main HTML page)
     - `style.css` (stylesheet)
     - `script.js` (JavaScript functionality)
   - Or drag and drop files

3. **Set Permissions** (Important)
   - Under **"Permissions"**, ensure public-read access will be granted via bucket policy (next step)

4. **Upload Files**
   - Click **"Upload"**
   - Wait for "Upload succeeded" confirmation
   - Click **"Close"**

5. **Verify Upload**
   - Confirm all three files appear in the bucket

---

### **STEP 4: Configure Bucket Policy (Public Read Access)**

1. **Navigate to Permissions**
   - Click **"Permissions"** tab
   - Scroll to **"Bucket policy"** section

2. **Edit Bucket Policy**
   - Click **"Edit"**

3. **Add Public Read Policy**
   - Paste the following JSON policy
   - ⚠️ **Replace `YOUR-BUCKET-NAME`** with your actual bucket name

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
    }
  ]
}
```

**Example:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-static-website-demo-12345/*"
    }
  ]
}
```

4. **Save Policy**
   - Click **"Save changes"**
   - You should see "Publicly accessible" badge on bucket

5. **Test S3 Website Endpoint** (Optional)
   - Open the S3 website endpoint URL in browser
   - Your website should load (HTTP only)

---

### **STEP 5: Create CloudFront Distribution**

1. **Navigate to CloudFront Console**
   - AWS Console → Services → CloudFront
   - Click **"Create distribution"**

2. **Configure Origin Settings**
   - **Origin domain**: 
     - Click the dropdown and select your S3 bucket
     - 🎯 Use the **bucket regional endpoint** (e.g., `bucket-name.s3.us-east-1.amazonaws.com`)
     - ❌ Don't use the website endpoint
   - **Origin path**: Leave blank
   - **Name**: Auto-filled (e.g., `my-bucket.s3.us-east-1.amazonaws.com`)
   - **Origin access**: Select **"Public"**
   - **Enable Origin Shield**: No

3. **Default Cache Behavior Settings**
   - **Path pattern**: Default (*)
   - **Compress objects automatically**: Yes
   - **Viewer protocol policy**: **"Redirect HTTP to HTTPS"** ✅
   - **Allowed HTTP methods**: GET, HEAD (default)
   - **Restrict viewer access**: No

4. **Cache Key and Origin Requests**
   - **Cache policy**: CachingOptimized (recommended)
   - **Origin request policy**: None
   - **Response headers policy**: None

5. **Function Associations** (Optional)
   - Leave as default (none)

6. **Distribution Settings**
   - **Price class**: 
     - "Use all edge locations" (best performance)
     - Or "Use only North America and Europe" (lower cost)
   - **AWS WAF web ACL**: None (unless you need WAF protection)
   - **Alternate domain name (CNAME)**: Leave blank (or add custom domain)
   - **Custom SSL certificate**: Default CloudFront certificate
   - **Supported HTTP versions**: HTTP/2, HTTP/1.1
   - **Default root object**: **`index.html`** ✅
   - **Standard logging**: Off (or enable for access logs)
   - **IPv6**: On
   - **Description**: "Static website distribution" (optional)

7. **Create Distribution**
   - Click **"Create distribution"**
   - ⏱️ **Wait 5-15 minutes** for deployment
   - Status will show "Enabled" and State "Deploying" → "Deployed"

8. **Get CloudFront Domain**
   - Once deployed, note the **Distribution domain name**
   - Example: `d1234abcd5678e.cloudfront.net`

---

### **STEP 6: Test Your Website**

1. **Access via CloudFront URL**
   - Open browser
   - Navigate to: `https://YOUR-DISTRIBUTION-DOMAIN.cloudfront.net`
   - Example: `https://d1234abcd5678e.cloudfront.net`
   - ✅ Website should load with HTTPS

2. **Verify Functionality**
   - Check if HTML renders correctly
   - Verify CSS styles are applied
   - Test JavaScript interactivity (if any)
   - Check browser console for errors (F12)

3. **Test HTTPS Redirect**
   - Try accessing `http://` (without 's')
   - Should automatically redirect to `https://`

4. **Test from Different Locations** (Optional)
   - Use VPN or ask someone in different region
   - CloudFront should deliver from nearest edge location

---

## 🧹 Manual Cleanup (To Avoid Charges)

### 1. Delete CloudFront Distribution
   - CloudFront Console → Distributions
   - Select your distribution
   - Click **"Disable"**
   - Wait 5-10 minutes for disable to complete
   - Click **"Delete"**

### 2. Empty and Delete S3 Bucket
   - S3 Console → Select your bucket
   - Click **"Empty"** (removes all objects)
   - Confirm by typing "permanently delete"
   - Click **"Delete bucket"**
   - Confirm by entering bucket name

---

## 🔧 Understanding Key Concepts

### S3 Static Website Hosting
- S3 can serve static content directly as a website
- Requires public read access to files
- Provides HTTP endpoint (no HTTPS)
- Very cost-effective for static content

### CloudFront CDN
- **Content Delivery Network**: Caches content at edge locations globally
- **Edge Locations**: 450+ locations worldwide for low latency
- **Origin**: Source of content (your S3 bucket)
- **Cache Behavior**: Rules for caching and serving content
- **HTTPS**: Free SSL/TLS with default certificate

### MIME Types
- Files need correct `Content-Type` headers
- HTML: `text/html`
- CSS: `text/css`
- JS: `application/javascript`
- S3 auto-detects based on file extension

### Bucket Policy vs ACL
- **Bucket Policy**: JSON-based access control (recommended)
- **ACL**: Legacy access control method
- Modern approach: Use bucket policies with ACLs disabled

---

## 🎯 Terraform Automation Benefits

After understanding the manual process, Terraform will:

✅ **Automate** all 6 steps above with code  
✅ **Version control** your infrastructure  
✅ **Reproduce** exact same setup anytime  
✅ **Update** infrastructure with code changes  
✅ **Delete** everything with one command  
✅ **Share** configuration with team  

---

## 📊 Resource Summary

| Resource | Purpose | Manual Steps | Terraform Resource |
|----------|---------|--------------|-------------------|
| S3 Bucket | Store website files | Steps 1-2 | `aws_s3_bucket` |
| S3 Objects | Website files | Step 3 | `aws_s3_object` |
| Bucket Policy | Public access | Step 4 | `aws_s3_bucket_policy` |
| CloudFront | Global CDN | Step 5 | `aws_cloudfront_distribution` |

---

## 💰 Cost Estimation

**Monthly costs for a small website (< 100GB storage, < 100K requests):**

| Service | Usage | Cost |
|---------|-------|------|
| S3 Storage | 1 GB | $0.023 |
| S3 Requests | 10,000 GET | ~$0.01 |
| CloudFront | 10 GB transfer | Free tier |
| CloudFront | 10,000 requests | Free tier |
| **Total** | | **~$0.05/month** |

**Free Tier Benefits:**
- S3: 5 GB storage, 20,000 GET requests (first 12 months)
- CloudFront: 1 TB data transfer out, 10M requests (always free)

---

## 🚀 Next Steps

Now that you understand the manual process:

1. ✅ Review the existing Terraform files in this directory
2. ✅ Compare Terraform code with manual steps
3. ✅ Run `terraform init` to initialize
4. ✅ Run `terraform plan` to see what will be created
5. ✅ Run `terraform apply` to deploy automatically
6. ✅ Test your deployed website
7. ✅ Run `terraform destroy` to clean up

---

## 📚 Additional Learning Resources

- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/cloudfront/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [S3 Bucket Policy Examples](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html)

---

## ⚠️ Important Notes

1. **Bucket names must be globally unique** across all AWS accounts
2. **CloudFront deployment takes 5-15 minutes** - be patient
3. **CloudFront changes can take time to propagate** to all edge locations
4. **Always delete CloudFront first** before deleting S3 bucket
5. **Monitor AWS costs** in Billing Dashboard
6. **Use Terraform for cleanup** - it's safer and faster

---

## 🎉 Conclusion

You now understand:
- How to manually deploy a static website on AWS
- The purpose of each AWS service (S3 + CloudFront)
- Why this architecture is cost-effective and scalable
- How Terraform will automate this entire process

Ready to implement with Terraform! 🚀

---

## 🚀 Advanced Extensions (Production-Ready Setup)

Once you've mastered the basic setup, consider these production enhancements:

---

### 1️⃣ Custom Domain Name with Route 53

#### **STEP 1: Register or Transfer Domain**

1. **Navigate to Route 53 Console**
   - AWS Console → Services → Route 53
   - Click **"Registered domains"**

2. **Register New Domain** (if you don't have one)
   - Click **"Register domain"**
   - Search for your desired domain (e.g., `mywebsite.com`)
   - Select domain and click **"Proceed to checkout"**
   - Fill contact information
   - Complete payment (domains cost $12-$15/year typically)
   - Wait for registration (can take minutes to hours)

3. **Or Use Existing Domain**
   - If registered elsewhere (GoDaddy, Namecheap), you can:
     - Transfer to Route 53, OR
     - Update nameservers to point to Route 53

#### **STEP 2: Create Hosted Zone** (Auto-created if registered in Route 53)

1. **Hosted Zones**
   - Route 53 → **"Hosted zones"**
   - Should auto-create for registered domains
   - Note the **4 nameservers** (NS records)

2. **If Using External Registrar**
   - Create hosted zone manually
   - Update nameservers at your registrar

#### **STEP 3: Update CloudFront Distribution**

1. **CloudFront Console** → Your distribution → **Edit**

2. **Alternate Domain Names (CNAMEs)**
   - Add your domain: `mywebsite.com`
   - Add www subdomain: `www.mywebsite.com`
   - Click **"Add item"** for each

3. **SSL Certificate**
   - Select **"Custom SSL certificate"**
   - Choose your ACM certificate (see next section)

4. **Save Changes**

#### **STEP 4: Create Route 53 DNS Records**

1. **Hosted Zone** → Your domain → **Create record**

2. **Root Domain Record**
   - **Record name**: Leave blank (for mywebsite.com)
   - **Record type**: A - IPv4 address
   - **Alias**: Toggle ON
   - **Route traffic to**: 
     - Select: "Alias to CloudFront distribution"
     - Choose your distribution from dropdown
   - **Routing policy**: Simple routing
   - Click **"Create records"**

3. **WWW Subdomain Record**
   - **Record name**: `www`
   - **Record type**: A - IPv4 address
   - **Alias**: Toggle ON
   - **Route traffic to**: Same CloudFront distribution
   - Click **"Create records"**

4. **Verify DNS Propagation** (takes 5-60 minutes)
   ```bash
   nslookup mywebsite.com
   ```

---

### 2️⃣ SSL Certificate with AWS Certificate Manager (ACM)

⚠️ **IMPORTANT**: ACM certificates for CloudFront **MUST** be created in **us-east-1** region!

#### **STEP 1: Request Public Certificate**

1. **Navigate to ACM Console**
   - AWS Console → **Switch Region to us-east-1** ✅
   - Services → Certificate Manager
   - Click **"Request a certificate"**

2. **Certificate Type**
   - Select **"Request a public certificate"**
   - Click **"Next"**

3. **Domain Names**
   - **Fully qualified domain name**: `mywebsite.com`
   - Click **"Add another name to this certificate"**
   - Add: `*.mywebsite.com` (wildcard for all subdomains)
   - Or specifically add: `www.mywebsite.com`

4. **Validation Method**
   - Select **"DNS validation"** (recommended)
   - DNS validation is easier and auto-renews
   - Click **"Next"**

5. **Tags** (Optional)
   - Add tags like: `Project: StaticWebsite`
   - Click **"Next"**

6. **Review and Request**
   - Review details
   - Click **"Request"**

#### **STEP 2: Validate Domain Ownership**

1. **Validation Status**
   - Certificate status shows "Pending validation"
   - Click on the certificate ID

2. **DNS Validation Records**
   - Expand domain names section
   - Click **"Create records in Route 53"** (if using Route 53)
   - AWS will automatically create CNAME records
   - Click **"Create records"**

3. **Wait for Validation**
   - Validation takes 5-30 minutes
   - Status changes from "Pending" → **"Issued"**
   - Certificate auto-renews before expiration

4. **If Using External DNS**
   - Manually copy CNAME record name and value
   - Add to your DNS provider
   - Wait for validation

#### **STEP 3: Attach to CloudFront**

1. **CloudFront Console** → Your distribution → **Edit**

2. **SSL Certificate Settings**
   - Under **"Custom SSL certificate"**
   - Click refresh icon
   - Select your certificate from dropdown
   - Shows: `mywebsite.com (and 1 more)`

3. **Security Policy**
   - Select **"TLSv1.2_2021"** (recommended)
   - Supports modern browsers with strong security

4. **Save Changes**
   - Wait 5-10 minutes for deployment

#### **STEP 4: Test HTTPS**

- Visit: `https://mywebsite.com`
- Click padlock icon in browser
- Verify certificate is valid and trusted
- Check certificate details show correct domain

---

### 3️⃣ CI/CD Pipeline for Automatic Deployments

#### **Option A: GitHub Actions Workflow**

**STEP 1: Create GitHub Repository**
- Initialize git repo in your website folder
- Push to GitHub

**STEP 2: Setup AWS Credentials in GitHub**

1. **Create IAM User for GitHub Actions**
   - IAM Console → Users → **"Create user"**
   - Username: `github-actions-deploy`
   - Attach policies:
     - `AmazonS3FullAccess`
     - `CloudFrontFullAccess`
   - Create access key → Save credentials

2. **Add Secrets to GitHub**
   - Repository → Settings → Secrets and variables → Actions
   - Click **"New repository secret"**
   - Add secrets:
     - `AWS_ACCESS_KEY_ID`: (your access key)
     - `AWS_SECRET_ACCESS_KEY`: (your secret key)
     - `AWS_REGION`: `us-east-1`
     - `S3_BUCKET`: `your-website-bucket-name`
     - `CLOUDFRONT_DISTRIBUTION_ID`: (from CloudFront console)

**STEP 3: Create GitHub Actions Workflow**

Create file: `.github/workflows/deploy.yml`

```yaml
name: Deploy to S3 and CloudFront

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}
    
    - name: Sync files to S3
      run: |
        aws s3 sync ./website s3://${{ secrets.S3_BUCKET }}/ \
          --delete \
          --cache-control "public, max-age=3600"
    
    - name: Invalidate CloudFront cache
      run: |
        aws cloudfront create-invalidation \
          --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
          --paths "/*"
```

**STEP 4: Deploy**
- Push changes to main branch
- GitHub Actions automatically deploys
- Check Actions tab for deployment status

---

#### **Option B: AWS CodePipeline**

**STEP 1: Create CodeCommit Repository** (or connect GitHub)

1. **CodeCommit Console** → **"Create repository"**
   - Repository name: `static-website`
   - Push your code

**STEP 2: Create CodeBuild Project**

1. **CodeBuild Console** → **"Create build project"**

2. **Project Configuration**
   - Name: `website-build`
   - Source: CodeCommit / GitHub
   - Repository: Select your repo
   - Branch: `main`

3. **Environment**
   - Managed image
   - OS: Ubuntu
   - Runtime: Standard
   - Image: Latest

4. **Buildspec**

Create `buildspec.yml` in repo root:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
  build:
    commands:
      - echo "Syncing to S3..."
      - aws s3 sync ./website s3://YOUR-BUCKET-NAME/ --delete
      - echo "Invalidating CloudFront..."
      - aws cloudfront create-invalidation --distribution-id YOUR-DIST-ID --paths "/*"

artifacts:
  files:
    - '**/*'
  base-directory: website
```

**STEP 3: Create CodePipeline**

1. **CodePipeline Console** → **"Create pipeline"**

2. **Pipeline Settings**
   - Name: `website-deployment`
   - Service role: New service role

3. **Source Stage**
   - Provider: CodeCommit / GitHub
   - Repository: Your repo
   - Branch: `main`
   - Detection: CloudWatch Events

4. **Build Stage**
   - Provider: AWS CodeBuild
   - Project: Select your CodeBuild project

5. **Deploy Stage**
   - Skip (handled in build stage)

6. **Review and Create**

**STEP 4: Test Pipeline**
- Commit and push changes
- Pipeline auto-triggers
- Watch stages execute in console

---

### 4️⃣ Multiple Environments (Dev, Staging, Prod)

#### **Strategy: Separate Resources per Environment**

**STEP 1: Naming Convention**

Create separate buckets and distributions:
- `mywebsite-dev.example.com` → Dev environment
- `mywebsite-staging.example.com` → Staging
- `mywebsite.com` → Production

**STEP 2: Create Dev Environment**

1. **S3 Bucket**: `mywebsite-dev-12345`
2. **CloudFront**: Point to dev bucket
3. **Route 53**: Create A record for `dev.mywebsite.com`
4. **ACM Certificate**: Include `dev.mywebsite.com` in certificate

**STEP 3: Create Staging Environment**

Same process with:
- S3: `mywebsite-staging-12345`
- CloudFront: Separate distribution
- DNS: `staging.mywebsite.com`

**STEP 4: Promotion Workflow**

```bash
# Deploy to dev
aws s3 sync ./website s3://mywebsite-dev-12345/

# Test dev environment
# If tests pass, promote to staging
aws s3 sync s3://mywebsite-dev-12345/ s3://mywebsite-staging-12345/

# Test staging
# If approved, promote to production
aws s3 sync s3://mywebsite-staging-12345/ s3://mywebsite-prod-12345/
```

**STEP 5: Environment Variables**

Use different configs per environment:

```javascript
// config.dev.js
const config = {
  apiUrl: 'https://api-dev.example.com',
  environment: 'development'
};

// config.prod.js
const config = {
  apiUrl: 'https://api.example.com',
  environment: 'production'
};
```

---

### 5️⃣ Advanced CloudFront Configurations

#### **A. Custom Error Pages**

**STEP 1: Create Error Pages**

Create custom HTML files:
- `404.html` - Page not found
- `500.html` - Server error
- `403.html` - Forbidden

**STEP 2: Upload to S3**
```bash
aws s3 cp 404.html s3://your-bucket/
aws s3 cp 500.html s3://your-bucket/
```

**STEP 3: Configure CloudFront**

1. **CloudFront Console** → Distribution → **Error pages**
2. **Create custom error response**
   - HTTP error code: **404**
   - Customize error response: **Yes**
   - Response page path: `/404.html`
   - HTTP response code: **404** (or 200 for SPA)
   - TTL: 300 seconds
3. Repeat for 500, 403, etc.

---

#### **B. Security Headers**

**Option 1: CloudFront Functions**

1. **CloudFront Console** → **Functions** → **Create function**

2. **Function Details**
   - Name: `security-headers`
   - Runtime: CloudFront Functions

3. **Function Code**

```javascript
function handler(event) {
    var response = event.response;
    var headers = response.headers;
    
    // Security headers
    headers['strict-transport-security'] = { 
        value: 'max-age=31536000; includeSubDomains; preload'
    };
    headers['x-content-type-options'] = { 
        value: 'nosniff'
    };
    headers['x-frame-options'] = { 
        value: 'DENY'
    };
    headers['x-xss-protection'] = { 
        value: '1; mode=block'
    };
    headers['referrer-policy'] = { 
        value: 'strict-origin-when-cross-origin'
    };
    headers['content-security-policy'] = {
        value: "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
    };
    
    return response;
}
```

4. **Publish Function**
   - Click **"Publish"**

5. **Associate with Distribution**
   - Distribution → Behaviors → Edit
   - **Function associations**
   - **Viewer response**: Select your function
   - Save

---

#### **C. Geo-Restrictions**

1. **CloudFront Console** → Distribution → **Restrictions**
2. **Edit Geo-Restriction**
   - **Enable**: Yes
   - **Restriction type**: Whitelist or Blacklist
   - **Countries**: Select countries to allow/block
3. **Save**

---

#### **D. Access Logs**

1. **Create Log Bucket**
   ```bash
   aws s3 mb s3://mywebsite-cloudfront-logs
   ```

2. **CloudFront Console** → Distribution → **Edit**
   - **Standard logging**: On
   - **S3 bucket**: `mywebsite-cloudfront-logs.s3.amazonaws.com`
   - **Log prefix**: `cloudfront/`
   - **Cookie logging**: Off (unless needed)

3. **Analyze Logs**
   - Use AWS Athena for SQL queries
   - Or download and analyze locally

---

#### **E. WAF (Web Application Firewall)**

1. **AWS WAF Console** → **Create web ACL**

2. **Web ACL Details**
   - Name: `website-waf`
   - CloudWatch metric: `websiteWAF`
   - Resource type: **CloudFront distributions**
   - Select your distribution

3. **Add Rules**
   - **AWS Managed Rules**:
     - Core rule set
     - Known bad inputs
     - SQL injection protection
     - Linux/Unix/PHP exploits
   - **Rate-based rules**: Limit requests per IP
   - **IP set rules**: Block/allow specific IPs

4. **Default Action**
   - Select **Allow** (blocks only if rules match)

5. **Review and Create**

---

## 📊 Cost Estimation for Production Setup

| Service | Usage | Monthly Cost |
|---------|-------|--------------|
| Route 53 | 1 hosted zone | $0.50 |
| Route 53 | 1M queries | $0.40 |
| ACM Certificate | Unlimited | **FREE** |
| S3 (3 environments) | 3 GB storage | $0.07 |
| CloudFront (3 dists) | 30 GB transfer | Free tier |
| CodePipeline | 1 active pipeline | $1.00 |
| WAF | 1 Web ACL + rules | $5.00 |
| **Total** | | **~$7/month** |

---

## 🎓 Learning Path Progression

**Phase 1: Basic Setup** ✅
- S3 + CloudFront
- Default domain
- Manual deployment

**Phase 2: Custom Domain** 🔄
- Route 53 DNS
- ACM SSL certificate
- Professional domain

**Phase 3: Automation** 🤖
- CI/CD pipeline
- Automated deployments
- Testing workflows

**Phase 4: Production** 🚀
- Multiple environments
- Security headers
- WAF protection
- Monitoring & logs

---

## 📚 Additional Resources for Extensions

- [Route 53 Developer Guide](https://docs.aws.amazon.com/route53/)
- [ACM User Guide](https://docs.aws.amazon.com/acm/)
- [CloudFront Functions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html)
- [AWS CodePipeline Guide](https://docs.aws.amazon.com/codepipeline/)
- [GitHub Actions for AWS](https://github.com/aws-actions)
- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)

---

Ready to take your static website to production level! 🎉
