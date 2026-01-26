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
