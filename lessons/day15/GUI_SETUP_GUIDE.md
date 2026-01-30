# Day 15: VPC Peering - Complete GUI-Based Setup Guide

## Table of Contents
1. [Console Navigation Overview](#console-navigation-overview)
2. [Prerequisites Setup](#prerequisites-setup)
3. [Step-by-Step GUI Setup](#step-by-step-gui-setup)
4. [Testing & Verification](#testing--verification)
5. [Troubleshooting](#troubleshooting)
6. [Cleanup](#cleanup)

---

## Console Navigation Overview

### AWS Management Console Regions
You'll be working with **two regions** throughout this guide:
- **Primary Region:** `us-east-1` (N. Virginia)
- **Secondary Region:** `us-west-2` (Oregon)

**How to Switch Regions:**
1. Look at the top-right corner of the AWS Console
2. Click on the **region dropdown** (currently showing your selected region)
3. Select the desired region from the list
4. The page will reload with resources for that region

---

## Prerequisites Setup

### Prerequisite 1: Create EC2 Key Pairs via Console

#### For us-east-1:
1. **Navigate to EC2 Key Pairs:**
   - Go to AWS Console → Search for "EC2"
   - In the left sidebar, scroll down to "Network & Security" section
   - Click **"Key Pairs"**

2. **Ensure you're in us-east-1:**
   - Top-right dropdown should show "US East (N. Virginia)"

3. **Create Key Pair:**
   - Click **"Create key pair"** button (orange/red button)
   - **Key pair name:** `vpc-peering-demo-east`
   - **Key pair type:** RSA
   - **Private key file format:** .pem (for Linux/Mac) or .ppk (for PuTTY on Windows)
   - Click **"Create key pair"**
   - **Important:** The .pem file will auto-download. Save it securely
   - Set file permissions: `chmod 400 vpc-peering-demo-east.pem` (on Linux/Mac)

4. **Verify Creation:**
   - You should see the key in the "Key Pairs" list

#### For us-west-2:
1. **Switch Region:** Top-right dropdown → Select "US West (Oregon)"
2. **Repeat the same process:**
   - Click **Key Pairs** in the left sidebar
   - Click **"Create key pair"**
   - **Key pair name:** `vpc-peering-demo-west`
   - **Key pair type:** RSA
   - **Private key file format:** .pem
   - Click **"Create key pair"**
   - Save the downloaded .pem file

---

## Step-by-Step GUI Setup

### STEP 1: Create Primary VPC (us-east-1)

#### 1.1 Navigate to VPC Dashboard

1. **Go to AWS Console Home**
2. **Search for "VPC"** in the search bar at the top
3. **Click "VPC"** from the search results
4. You'll see the VPC Dashboard

#### 1.2 Verify Region
- Top-right shows "US East (N. Virginia)" ✅
- If not, switch to us-east-1

#### 1.3 Create VPC

1. In the left sidebar, click **"Your VPCs"**
2. Click **"Create VPC"** button (orange button)
3. **Configuration Form:**
   ```
   Name tag (optional):        Primary-VPC
   IPv4 CIDR block:            10.0.0.0/16
   IPv6 CIDR block:            (leave blank)
   Tenancy:                     Default
   ```
4. **Advanced Options:**
   - **DNS hostnames:** ☑️ Enable
   - **DNS resolution:** ☑️ Enable

5. Click **"Create VPC"** button

#### 1.4 Verify Creation
- You should see "Primary-VPC" listed in "Your VPCs"
- Copy and save the **VPC ID** (format: `vpc-xxxxxxxxx`)

---

### STEP 2: Create Secondary VPC (us-west-2)

#### 2.1 Switch to us-west-2
- Top-right dropdown → Select "US West (Oregon)"

#### 2.2 Create VPC
1. Left sidebar → **"Your VPCs"**
2. Click **"Create VPC"** button
3. **Configuration Form:**
   ```
   Name tag (optional):        Secondary-VPC
   IPv4 CIDR block:            10.1.0.0/16
   IPv6 CIDR block:            (leave blank)
   Tenancy:                     Default
   ```
4. **Advanced Options:**
   - **DNS hostnames:** ☑️ Enable
   - **DNS resolution:** ☑️ Enable

5. Click **"Create VPC"** button

#### 2.3 Verify Creation
- Copy and save the **VPC ID** for Secondary VPC

---

### STEP 3: Create Subnets

#### 3.1 Create Primary Subnet (us-east-1)

1. **Switch to us-east-1** (top-right dropdown)
2. Left sidebar → Click **"Subnets"**
3. Click **"Create subnet"** button
4. **Subnet Settings:**
   ```
   VPC ID:                     Primary-VPC (select from dropdown)
   Subnet name:                Primary-Subnet
   Availability Zone:          us-east-1a (or any default)
   IPv4 CIDR block:            10.0.1.0/24
   ```
5. Click **"Create subnet"**

#### 3.2 Enable Auto-Assign Public IP for Primary Subnet

1. In the Subnets list, click on **"Primary-Subnet"**
2. Click the **"Actions"** button (top-right)
3. Click **"Edit subnet settings"**
4. Check the box: **"Enable auto-assign public IPv4 address"** ☑️
5. Click **"Save"**

#### 3.3 Create Secondary Subnet (us-west-2)

1. **Switch to us-west-2**
2. Left sidebar → **"Subnets"**
3. Click **"Create subnet"**
4. **Subnet Settings:**
   ```
   VPC ID:                     Secondary-VPC
   Subnet name:                Secondary-Subnet
   Availability Zone:          us-west-2a (or any default)
   IPv4 CIDR block:            10.1.1.0/24
   ```
5. Click **"Create subnet"**

#### 3.4 Enable Auto-Assign Public IP for Secondary Subnet

1. Click on **"Secondary-Subnet"** from the list
2. Click **"Actions"** button
3. Click **"Edit subnet settings"**
4. Check the box: **"Enable auto-assign public IPv4 address"** ☑️
5. Click **"Save"**

---

### STEP 4: Create and Attach Internet Gateways

#### 4.1 Create Primary Internet Gateway (us-east-1)

1. **Switch to us-east-1**
2. Left sidebar → Click **"Internet Gateways"**
3. Click **"Create internet gateway"** button
4. **Configuration:**
   ```
   Name tag:                   Primary-IGW
   ```
5. Click **"Create internet gateway"**
6. You'll see a **success banner** with "Attach to VPC" button
7. Click **"Attach to VPC"**
8. **Select VPC:**
   ```
   VPC:                        Primary-VPC (select from dropdown)
   ```
9. Click **"Attach internet gateway"**

#### 4.2 Create Secondary Internet Gateway (us-west-2)

1. **Switch to us-west-2**
2. Left sidebar → **"Internet Gateways"**
3. Click **"Create internet gateway"**
4. **Configuration:**
   ```
   Name tag:                   Secondary-IGW
   ```
5. Click **"Create internet gateway"**
6. Click **"Attach to VPC"** button from success banner
7. **Select VPC:**
   ```
   VPC:                        Secondary-VPC
   ```
8. Click **"Attach internet gateway"**

---

### STEP 5: Create and Configure Route Tables

#### 5.1 Create Primary Route Table (us-east-1)

1. **Switch to us-east-1**
2. Left sidebar → Click **"Route Tables"**
3. Click **"Create route table"** button
4. **Configuration:**
   ```
   Name:                       Primary-Route-Table
   VPC:                        Primary-VPC (select from dropdown)
   ```
5. Click **"Create route table"**

#### 5.2 Add Internet Route to Primary Route Table

1. In Route Tables list, click on **"Primary-Route-Table"**
2. Scroll down to **"Routes"** section
3. Click **"Edit routes"** button
4. Click **"Add route"** button
5. **Route Configuration:**
   ```
   Destination:                0.0.0.0/0
   Target:                     Internet Gateway → Primary-IGW (select from dropdown)
   ```
6. Click **"Save changes"**

#### 5.3 Associate Primary Route Table with Primary Subnet

1. Still in the Route Table details page
2. Scroll down to **"Subnet Associations"** section
3. Click **"Edit subnet associations"**
4. Check the box next to **"Primary-Subnet"** ☑️
5. Click **"Save associations"**

#### 5.4 Create Secondary Route Table (us-west-2)

1. **Switch to us-west-2**
2. Left sidebar → **"Route Tables"**
3. Click **"Create route table"**
4. **Configuration:**
   ```
   Name:                       Secondary-Route-Table
   VPC:                        Secondary-VPC
   ```
5. Click **"Create route table"**

#### 5.5 Add Internet Route to Secondary Route Table

1. Click on **"Secondary-Route-Table"** from the list
2. Scroll down to **"Routes"** section
3. Click **"Edit routes"**
4. Click **"Add route"**
5. **Route Configuration:**
   ```
   Destination:                0.0.0.0/0
   Target:                     Internet Gateway → Secondary-IGW
   ```
6. Click **"Save changes"**

#### 5.6 Associate Secondary Route Table with Secondary Subnet

1. Still in the Route Table details page
2. Scroll down to **"Subnet Associations"**
3. Click **"Edit subnet associations"**
4. Check the box next to **"Secondary-Subnet"** ☑️
5. Click **"Save associations"**

---

### STEP 6: Create VPC Peering Connection

#### 6.1 Create Peering Connection (from Primary VPC)

1. **Switch to us-east-1**
2. Left sidebar → Click **"Peering Connections"**
3. Click **"Create peering connection"** button
4. **Configuration:**
   ```
   Peering connection name:    Primary-to-Secondary-Peering
   VPC ID (Requester):         Primary-VPC
   Account:                    My account (default)
   Region:                     us-west-2
   VPC ID (Accepter):          Secondary-VPC (type or select)
   ```
5. Click **"Create peering connection"**

#### 6.2 Accept Peering Connection (from Secondary VPC)

1. You'll see a success message with an option
2. Click **"Accept request"** button or navigate to **Peering Connections** in us-west-2

**If you missed the button:**
1. **Switch to us-west-2**
2. Left sidebar → **"Peering Connections"**
3. You'll see a peering connection with status **"Pending Acceptance"**
4. Click on it to select it
5. Click **"Actions"** button
6. Click **"Accept request"**
7. Click **"Accept peering connection"** in the dialog

#### 6.3 Verify Peering Connection Status

1. Go to **Peering Connections** in either region
2. Look for the peering connection you created
3. **Status should be "Active"** ✅

---

### STEP 7: Add Peering Routes to Route Tables

#### 7.1 Add Route from Primary to Secondary (us-east-1)

1. **Switch to us-east-1**
2. Left sidebar → **"Route Tables"**
3. Click on **"Primary-Route-Table"**
4. Scroll to **"Routes"** section
5. Click **"Edit routes"**
6. Click **"Add route"**
7. **Route Configuration:**
   ```
   Destination:                10.1.0.0/16 (Secondary VPC CIDR)
   Target:                     Peering Connection → (select your peering connection)
   ```
8. Click **"Save changes"**

#### 7.2 Add Route from Secondary to Primary (us-west-2)

1. **Switch to us-west-2**
2. Left sidebar → **"Route Tables"**
3. Click on **"Secondary-Route-Table"**
4. Scroll to **"Routes"** section
5. Click **"Edit routes"**
6. Click **"Add route"**
7. **Route Configuration:**
   ```
   Destination:                10.0.0.0/16 (Primary VPC CIDR)
   Target:                     Peering Connection → (select your peering connection)
   ```
8. Click **"Save changes"**

---

### STEP 8: Create Security Groups

#### 8.1 Create Primary Security Group (us-east-1)

1. **Switch to us-east-1**
2. Left sidebar → Click **"Security Groups"** (under Network & Security)
3. Click **"Create security group"** button
4. **Basic Details:**
   ```
   Security group name:        Primary-VPC-SG
   Description:                Security group for Primary VPC instance
   VPC:                        Primary-VPC
   ```

#### 8.2 Add Inbound Rules to Primary Security Group

1. Scroll down to **"Inbound rules"**
2. Click **"Add rule"** button three times to add 3 rules:

**Rule 1: SSH**
```
Type:                         SSH
Protocol:                     TCP
Port range:                   22
Source:                       0.0.0.0/0 (anywhere)
Description:                  SSH from anywhere
```

**Rule 2: ICMP**
```
Type:                         All ICMP - IPv4
Protocol:                     ICMP
Port range:                   -1
Source:                       10.1.0.0/16 (Secondary VPC CIDR)
Description:                  ICMP from Secondary VPC
```

**Rule 3: HTTP from Peer VPC**
```
Type:                         HTTP
Protocol:                     TCP
Port range:                   80
Source:                       10.1.0.0/16
Description:                  HTTP from Secondary VPC
```

3. Click **"Create security group"**

#### 8.3 Create Secondary Security Group (us-west-2)

1. **Switch to us-west-2**
2. Left sidebar → **"Security Groups"**
3. Click **"Create security group"**
4. **Basic Details:**
   ```
   Security group name:        Secondary-VPC-SG
   Description:                Security group for Secondary VPC instance
   VPC:                        Secondary-VPC
   ```

#### 8.4 Add Inbound Rules to Secondary Security Group

1. Scroll to **"Inbound rules"**
2. Click **"Add rule"** three times:

**Rule 1: SSH**
```
Type:                         SSH
Protocol:                     TCP
Port range:                   22
Source:                       0.0.0.0/0
Description:                  SSH from anywhere
```

**Rule 2: ICMP**
```
Type:                         All ICMP - IPv4
Protocol:                     ICMP
Port range:                   -1
Source:                       10.0.0.0/16 (Primary VPC CIDR)
Description:                  ICMP from Primary VPC
```

**Rule 3: HTTP from Peer VPC**
```
Type:                         HTTP
Protocol:                     TCP
Port range:                   80
Source:                       10.0.0.0/16
Description:                  HTTP from Primary VPC
```

3. Click **"Create security group"**

---

### STEP 9: Launch EC2 Instances

#### 9.1 Launch Primary EC2 Instance (us-east-1)

1. **Switch to us-east-1**
2. Search for "EC2" in the top search bar
3. Click **"EC2"** from results
4. Left sidebar → Click **"Instances"**
5. Click **"Launch instances"** button

#### 9.2 Configure Primary Instance - Step 1: Name and OS

```
Name and tags:                Primary-VPC-Instance

Application and OS Images:
  - Quick Start tab (default)
  - Search: "ubuntu 24.04"
  - Select "Ubuntu Server 24.04 LTS (HVM)"
  - AMI should be marked "Free tier eligible"
```

Click **"Next"**

#### 9.3 Configure Primary Instance - Step 2: Instance Type

```
Instance type:                t2.micro (Free tier eligible)
```

Click **"Next"**

#### 9.4 Configure Primary Instance - Step 3: Network Settings

```
Network (VPC):                Primary-VPC
Subnet:                       Primary-Subnet
Auto-assign public IP:        Enable
Firewall (security groups):   Primary-VPC-SG
Key pair name:                vpc-peering-demo-east
```

Click **"Next"**

#### 9.5 Configure Primary Instance - Step 4: Storage

```
Root volume size:             8 GiB (default)
Volume type:                  gp3 (default)
Delete on termination:        ☑️ checked
```

Click **"Next"**

#### 9.6 Configure Primary Instance - Step 5: Advanced Details

Scroll down to **"User data"** section

Paste the following script:
```bash
#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Primary VPC Instance - us-east-1</h1>" > /var/www/html/index.html
echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
echo "<p>Region: us-east-1</p>" >> /var/www/html/index.html
```

Click **"Launch instance"** (orange button at bottom right)

#### 9.7 Verify Primary Instance Launch

- You should see a success message
- Click **"View all instances"** to see your instance launching
- Wait 2-3 minutes for the instance to enter **"running"** state

#### 9.8 Launch Secondary EC2 Instance (us-west-2)

1. **Switch to us-west-2**
2. EC2 → **"Instances"**
3. Click **"Launch instances"**

#### 9.9 Configure Secondary Instance - Step 1: Name and OS

```
Name and tags:                Secondary-VPC-Instance

Application and OS Images:
  - Search: "ubuntu 24.04"
  - Select "Ubuntu Server 24.04 LTS (HVM)"
```

Click **"Next"**

#### 9.10 Configure Secondary Instance - Step 2: Instance Type

```
Instance type:                t2.micro
```

Click **"Next"**

#### 9.11 Configure Secondary Instance - Step 3: Network Settings

```
Network (VPC):                Secondary-VPC
Subnet:                       Secondary-Subnet
Auto-assign public IP:        Enable
Firewall (security groups):   Secondary-VPC-SG
Key pair name:                vpc-peering-demo-west
```

Click **"Next"**

#### 9.12 Configure Secondary Instance - Step 4: Storage

```
Root volume size:             8 GiB
Volume type:                  gp3
Delete on termination:        ☑️
```

Click **"Next"**

#### 9.13 Configure Secondary Instance - Step 5: Advanced Details

Scroll to **"User data"** and paste:
```bash
#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Secondary VPC Instance - us-west-2</h1>" > /var/www/html/index.html
echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
echo "<p>Region: us-west-2</p>" >> /var/www/html/index.html
```

Click **"Launch instance"**

#### 9.14 Verify Secondary Instance Launch

- Check status: should be **"running"** after 2-3 minutes

---

### STEP 10: Collect Instance Details

#### 10.1 Get Primary Instance Details (us-east-1)

1. **Switch to us-east-1**
2. EC2 → **"Instances"**
3. Click on **"Primary-VPC-Instance"**
4. In the details panel below, locate:
   - **Private IP address** (format: 10.0.1.x)
   - **Public IP address** (format: x.x.x.x)
5. **Copy and save both IPs** for later testing

#### 10.2 Get Secondary Instance Details (us-west-2)

1. **Switch to us-west-2**
2. EC2 → **"Instances"**
3. Click on **"Secondary-VPC-Instance"**
4. In the details panel, locate:
   - **Private IP address** (format: 10.1.1.x)
   - **Public IP address** (format: x.x.x.x)
5. **Copy and save both IPs** for testing

---

## Testing & Verification

### Test 1: Verify VPC Peering Status

1. **Switch to us-east-1**
2. Left sidebar → **"Peering Connections"**
3. Click on your peering connection
4. **Verify:**
   - **Status:** Should be **"Active"** ✅
   - **Requester VPC:** Primary-VPC (us-east-1)
   - **Accepter VPC:** Secondary-VPC (us-west-2)

---

### Test 2: SSH into Primary Instance

1. Open Terminal/Command Prompt on your local machine
2. Navigate to the folder where you saved `vpc-peering-demo-east.pem`
3. Run the command:
   ```bash
   ssh -i vpc-peering-demo-east.pem ubuntu@<PRIMARY_PUBLIC_IP>
   ```
   Replace `<PRIMARY_PUBLIC_IP>` with the actual public IP

4. **First connection:**
   - Type `yes` when asked "Are you sure you want to continue connecting?"
   - Press Enter

5. **Success:** You should see the Ubuntu prompt:
   ```
   ubuntu@ip-10-0-1-x:~$
   ```

---

### Test 3: Ping Secondary Instance from Primary (via Private IP)

While still connected to Primary instance:

```bash
ping -c 4 <SECONDARY_PRIVATE_IP>
```

Replace with the actual secondary private IP (e.g., 10.1.1.x)

**Expected Output:**
```
PING 10.1.1.x (10.1.1.x) 56(84) bytes of data.
64 bytes from 10.1.1.x: icmp_seq=1 ttl=62 time=XX.X ms
64 bytes from 10.1.1.x: icmp_seq=2 ttl=62 time=XX.X ms
64 bytes from 10.1.1.x: icmp_seq=3 ttl=62 time=XX.X ms
64 bytes from 10.1.1.x: icmp_seq=4 ttl=62 time=XX.X ms

--- 10.1.1.x statistics ---
4 packets transmitted, 4 received, 0% packet loss, time XXms
```

**All packets received = VPC Peering is working!** ✅

---

### Test 4: SSH from Primary to Secondary

While still in Primary instance:

```bash
ssh ubuntu@<SECONDARY_PRIVATE_IP>
```

**Expected:** Should connect successfully (no public IP needed!)

---

### Test 5: Check Apache Web Server

While connected to Secondary instance:

```bash
curl localhost
```

**Expected Output:**
```html
<h1>Secondary VPC Instance - us-west-2</h1>
<p>Private IP: 10.1.1.x</p>
<p>Region: us-west-2</p>
```

---

### Test 6: Exit and Test Reverse Direction

Exit from Secondary:
```bash
exit
```

Exit from Primary:
```bash
exit
```

Now SSH into Secondary from your local machine:
```bash
ssh -i vpc-peering-demo-west.pem ubuntu@<SECONDARY_PUBLIC_IP>
```

Ping Primary:
```bash
ping -c 4 <PRIMARY_PRIVATE_IP>
```

**Should see all 4 packets received!** ✅

---

## Troubleshooting

### Issue 1: Cannot SSH - "Connection Timed Out"

**Possible Causes & Solutions:**

1. **Security Group Rule Missing**
   - Go to **EC2 → Instances**
   - Click the instance
   - Scroll down to **"Security groups"**
   - Click the security group
   - Check **"Inbound rules"** section
   - Should have SSH rule for port 22 from 0.0.0.0/0

2. **Wait for Instance Initialization**
   - Instance needs 2-3 minutes to boot
   - Check **Instance State:** should be **"running"** (green)
   - Wait another minute and retry

3. **Public IP Not Assigned**
   - Go to **EC2 → Instances**
   - Click the instance
   - Look for "Public IP address"
   - If empty, the instance didn't get a public IP
   - **Fix:** Select instance → **Instance State** → **Reboot instance**

4. **Wrong Key Pair**
   - Ensure you're using the correct .pem file
   - `vpc-peering-demo-east.pem` for us-east-1 instance
   - `vpc-peering-demo-west.pem` for us-west-2 instance

---

### Issue 2: Ping Fails Between Instances

**Possible Causes & Solutions:**

1. **VPC Peering Not Active**
   - Go to **VPC → Peering Connections**
   - Check **Status:** Must be **"Active"**
   - If **"Pending Acceptance":**
     - Go to us-west-2 region
     - Click the peering connection
     - Click **"Actions"** → **"Accept request"**

2. **Routes Not Configured**
   - Go to **VPC → Route Tables**
   - Click on **Primary-Route-Table**
   - Check **"Routes"** section
   - Should have:
     - `0.0.0.0/0` → IGW
     - `10.1.0.0/16` → Peering Connection

   - Click on **Secondary-Route-Table**
   - Should have:
     - `0.0.0.0/0` → IGW
     - `10.0.0.0/16` → Peering Connection

3. **Security Group Missing ICMP Rule**
   - Go to **EC2 → Security Groups**
   - Select **Primary-VPC-SG**
   - Check **"Inbound rules"**
   - Should have rule:
     ```
     Type: All ICMP - IPv4
     Source: 10.1.0.0/16
     ```
   - If missing, click **"Edit inbound rules"** and add it

   - Repeat for **Secondary-VPC-SG** with source `10.0.0.0/16`

---

### Issue 3: No Internet Access from Instance

**Problem:** Instance can't reach external websites

**Solutions:**

1. **Internet Gateway Attached**
   - Go to **VPC → Internet Gateways**
   - Click on your IGW
   - Look for **"Attached VPC"** field
   - Should show your VPC
   - If not, click **"Actions"** → **"Attach to VPC"**

2. **Route Table Has Default Route**
   - Go to **VPC → Route Tables**
   - Click your route table
   - Check **"Routes"** section
   - Should have:
     ```
     Destination: 0.0.0.0/0
     Target: Your Internet Gateway
     ```

---

### Issue 4: Security Group Rules Visible but Still Can't Connect

**Solution: Apply Changes**

Sometimes the console doesn't auto-save. Make sure to:
1. After adding/modifying rules, scroll down
2. Look for a **"Save rules"** or **"Apply changes"** button
3. Click it explicitly

---

## Cleanup

### Delete Everything in Correct Order

**Important:** Delete resources in this order to avoid dependency errors.

### Step 1: Terminate EC2 Instances

1. **Switch to us-east-1**
2. Go to **EC2 → Instances**
3. **Select** `Primary-VPC-Instance` (checkbox on left)
4. Click **"Instance State"** button (top menu)
5. Click **"Terminate instance"**
6. Click **"Terminate"** in the dialog

7. **Switch to us-west-2**
8. Go to **EC2 → Instances**
9. **Select** `Secondary-VPC-Instance`
10. Click **"Instance State"** → **"Terminate instance"**
11. Click **"Terminate"**

**Wait 1-2 minutes for termination to complete**

---

### Step 2: Delete VPC Peering Connection

1. **Switch to us-east-1** (or any region)
2. Go to **VPC → Peering Connections**
3. **Select** your peering connection
4. Click **"Actions"** button
5. Click **"Delete peering connection"**
6. Click **"Yes, delete"** in the confirmation dialog

---

### Step 3: Delete Route Tables (Custom Ones Only)

1. **Switch to us-east-1**
2. Go to **VPC → Route Tables**
3. **Select** `Primary-Route-Table`
4. Click **"Actions"** button
5. Click **"Delete route table"**
6. Click **"Delete"** in the dialog

7. **Switch to us-west-2**
8. Go to **VPC → Route Tables**
9. **Select** `Secondary-Route-Table`
10. Click **"Actions"** → **"Delete route table"**
11. Click **"Delete"**

---

### Step 4: Delete Security Groups

1. **Switch to us-east-1**
2. Go to **EC2 → Security Groups**
3. **Select** `Primary-VPC-SG`
4. Click **"Actions"** button
5. Click **"Delete security group"**
6. Click **"Delete"**

7. **Switch to us-west-2**
8. Go to **EC2 → Security Groups**
9. **Select** `Secondary-VPC-SG`
10. Click **"Actions"** → **"Delete security group"**
11. Click **"Delete"**

---

### Step 5: Detach Internet Gateways

1. **Switch to us-east-1**
2. Go to **VPC → Internet Gateways**
3. **Select** `Primary-IGW`
4. Click **"Actions"** button
5. Click **"Detach from VPC"**
6. Click **"Detach internet gateway"**

7. **Switch to us-west-2**
8. Go to **VPC → Internet Gateways**
9. **Select** `Secondary-IGW`
10. Click **"Actions"** → **"Detach from VPC"**
11. Click **"Detach internet gateway"**

---

### Step 6: Delete Internet Gateways

1. **In us-east-1** (still viewing IGWs):
   - **Select** `Primary-IGW`
   - Click **"Actions"** → **"Delete internet gateway"**
   - Click **"Delete"**

2. **In us-west-2**:
   - **Select** `Secondary-IGW`
   - Click **"Actions"** → **"Delete internet gateway"**
   - Click **"Delete"**

---

### Step 7: Delete Subnets

1. **Switch to us-east-1**
2. Go to **VPC → Subnets**
3. **Select** `Primary-Subnet`
4. Click **"Actions"** button
5. Click **"Delete subnet"**
6. Click **"Delete"**

7. **Switch to us-west-2**
8. Go to **VPC → Subnets**
9. **Select** `Secondary-Subnet`
10. Click **"Actions"** → **"Delete subnet"**
11. Click **"Delete"**

---

### Step 8: Delete VPCs

1. **Switch to us-east-1**
2. Go to **VPC → Your VPCs**
3. **Select** `Primary-VPC`
4. Click **"Actions"** button
5. Click **"Delete VPC"**
6. Click **"Delete"** in the dialog

7. **Switch to us-west-2**
8. Go to **VPC → Your VPCs**
9. **Select** `Secondary-VPC`
10. Click **"Actions"** → **"Delete VPC"**
11. Click **"Delete"**

---

### Step 9: Delete Key Pairs (Optional)

1. **Switch to us-east-1**
2. Go to **EC2 → Key Pairs**
3. **Select** `vpc-peering-demo-east`
4. Click **"Delete"** button
5. Type the key name to confirm
6. Click **"Delete"**

7. **Switch to us-west-2**
8. Go to **EC2 → Key Pairs**
9. **Select** `vpc-peering-demo-west`
10. Click **"Delete"**
11. Type the key name to confirm
12. Click **"Delete"**

---

### Step 10: Delete Local .pem Files

```bash
# On your local machine
rm vpc-peering-demo-east.pem vpc-peering-demo-west.pem
```

---

## Console Comparison Cheat Sheet

| Task | GUI Location | CLI Command Type |
|------|--------------|------------------|
| Create VPC | VPC → Your VPCs → Create VPC | `aws ec2 create-vpc` |
| Create Subnet | VPC → Subnets → Create subnet | `aws ec2 create-subnet` |
| Create IGW | VPC → Internet Gateways → Create | `aws ec2 create-internet-gateway` |
| Create Route Table | VPC → Route Tables → Create | `aws ec2 create-route-table` |
| Create Peering | VPC → Peering Connections → Create | `aws ec2 create-vpc-peering-connection` |
| Accept Peering | VPC → Peering Connections → Accept | `aws ec2 accept-vpc-peering-connection` |
| Launch Instance | EC2 → Instances → Launch instances | `aws ec2 run-instances` |
| Create Security Group | EC2 → Security Groups → Create | `aws ec2 create-security-group` |
| Edit Rules | SG → Inbound rules → Edit | `aws ec2 authorize-security-group-ingress` |
| View Details | Click resource in list → Details panel | `aws ec2 describe-*` |

---

## Key GUI Tips & Tricks

### 1. **Breadcrumb Navigation**
- At the top of each page, you'll see a breadcrumb trail (e.g., "EC2 > Instances")
- Click any part to go back

### 2. **Search & Filter**
- Use the **Search box** at the top to quickly find resources by ID or name
- Filters on the left side to narrow results

### 3. **Tag Resources**
- Always add **Name tag** when creating resources
- Makes it 10x easier to identify resources later

### 4. **Copy IDs**
- Hover over any ID (VPC ID, Subnet ID, etc.)
- Click the **copy icon** to automatically copy to clipboard

### 5. **Refresh Page**
- Press **F5** or click the **refresh icon** to update data
- The console doesn't auto-refresh every resource type

### 6. **Multiple Tabs**
- Open multiple browser tabs for different regions
- Switch between tabs to work in parallel

### 7. **Region Indicator**
- Always check the **top-right region dropdown**
- Easy to make mistakes by working in the wrong region

### 8. **Bookmark Shortcuts**
- VPC Dashboard: https://console.aws.amazon.com/vpc/
- EC2 Dashboard: https://console.aws.amazon.com/ec2/
- Bookmark for quick access

---

## Summary Checklist

- ✅ Created EC2 Key Pairs in both regions
- ✅ Created Primary VPC (10.0.0.0/16) in us-east-1
- ✅ Created Secondary VPC (10.1.0.0/16) in us-west-2
- ✅ Created subnets with auto-assign public IP enabled
- ✅ Created and attached Internet Gateways to both VPCs
- ✅ Created route tables with internet routes
- ✅ Associated route tables with subnets
- ✅ Created VPC Peering Connection
- ✅ Accepted peering connection
- ✅ Added peering routes to both route tables
- ✅ Created Security Groups with appropriate rules
- ✅ Launched EC2 instances with Apache web server
- ✅ Verified VPC peering status (Active)
- ✅ Tested SSH connectivity
- ✅ Tested ping between instances (via private IPs)
- ✅ Tested cross-instance SSH
- ✅ Verified web server
- ✅ Cleaned up all resources

---

## Learning Outcomes

### What You've Learned:

1. **VPC Architecture:**
   - How to design VPCs with appropriate CIDR blocks
   - Subnet placement and IP distribution
   - Internet Gateway role in public connectivity

2. **VPC Peering:**
   - Creating peering connections across regions
   - Accepting peering requests
   - Configuring routes for peering traffic

3. **Security:**
   - Security Group ingress rules
   - Principle of least privilege (specific CIDR blocks)
   - SSH key management

4. **EC2 Basics:**
   - Instance launch process
   - User data scripts for initialization
   - Public vs private IP addressing

5. **AWS Console Navigation:**
   - Switching between regions
   - Finding resources
   - Understanding service organization

### Real-World Applications:

- **Multi-Region Deployment:** Disaster recovery and redundancy
- **Hybrid Environments:** Connecting on-premise networks
- **Microservices:** Inter-service communication across regions
- **Cost Optimization:** Using peering instead of NAT gateways

---

## Key Concepts Demonstrated

### 1. VPC Peering
- **Cross-Region Peering:** Established connection between us-east-1 and us-west-2
- **Requester and Accepter:** Primary VPC initiates, Secondary VPC accepts
- **Active Status:** Peering must be in "active" state for traffic flow
- **Private IP Communication:** Resources use private IPs, no public internet

### 2. Routing Configuration
- **Route Tables:** Separate route tables for each VPC
- **Peering Routes:** Specific routes to peer VPC CIDR blocks
- **Internet Routes:** Default route (0.0.0.0/0) to Internet Gateway
- **Route Priority:** More specific routes take precedence

### 3. Security Architecture
- **Security Groups:** Stateful firewall rules at instance level
- **Cross-VPC Traffic:** Rules allowing traffic from peer VPC CIDR
- **ICMP and TCP Rules:** Ping and application-level communication
- **Egress Rules:** Implicit allow-all outbound (can be restricted)

### 4. Multi-Region Deployment
- **Region Independence:** Each region has its own resources
- **Cross-Region Dependencies:** Peering connects independent regions
- **AMI Selection:** Different AMI IDs per region
- **Latency Considerations:** Cross-region has higher latency than same-region

---

## Important Notes

### CIDR Block Requirements
**Critical:** VPC CIDR blocks **must NOT overlap** for peering to work!

✅ **Valid Example:**
```
Primary VPC:   10.0.0.0/16  (10.0.0.0 - 10.0.255.255)
Secondary VPC: 10.1.0.0/16  (10.1.0.0 - 10.1.255.255)
```

❌ **Invalid Example:**
```
Primary VPC:   10.0.0.0/16
Secondary VPC: 10.0.1.0/24  ← Overlaps with Primary!
```

**Planning Tip:** Always plan your CIDR blocks in advance if you anticipate future peering.

---

### AWS Costs & Billing

This setup creates resources that **incur AWS charges:**

**Compute Costs:**
- 2× EC2 t2.micro instances (~$0.0116/hour each)
- Approximately **$0.023/hour** or **$16.70/month** if left running

**Data Transfer Costs:**
- **Intra-region peering:** FREE
- **Cross-region peering:** 
  - $0.01/GB (us-east-1 to us-west-2)
  - $0.01/GB (us-west-2 to us-east-1)
- **Internet egress:** $0.09/GB (first 10 TB)

**VPC Peering Costs:**
- No hourly charge for peering connection itself
- Only pay for data transfer across the peering

**Cost Saving Tips:**
1. **Terminate instances** when not testing
2. **Use Free Tier:** t2.micro eligible for 750 hours/month
3. **Delete resources** after completing the demo
4. **Monitor usage** via AWS Cost Explorer

---

### VPC Peering Limitations

#### 1. Non-Transitive Routing
**VPC peering is NOT transitive:**
```
VPC-A ←→ VPC-B ←→ VPC-C
```
- VPC-A can talk to VPC-B ✅
- VPC-B can talk to VPC-C ✅
- VPC-A **CANNOT** talk to VPC-C ❌

**Solution:** Create direct peering between VPC-A and VPC-C, or use AWS Transit Gateway.

#### 2. No Edge-to-Edge Routing
**Cannot route through:**
- Internet Gateway in peer VPC
- NAT Gateway in peer VPC
- VPN connection in peer VPC
- AWS Direct Connect in peer VPC

**Workaround:** Each VPC needs its own gateway resources.

#### 3. Peering Connection Limits
- **Maximum:** 125 active peering connections per VPC
- **Maximum:** 125 pending peering requests

#### 4. DNS Resolution Limitations
- DNS hostnames don't automatically resolve across peers
- Private hosted zones require additional configuration
- Use private IPs or configure Route 53 private hosted zones

#### 5. Security Group Referencing
- Cannot reference security groups from peer VPC
- Must use CIDR blocks instead

---

## Additional Testing Scenarios

### Test 7: HTTP Connectivity Test

While SSH'd into Primary instance:
```bash
curl http://<SECONDARY_PRIVATE_IP>
```

**Expected Output:**
```html
<h1>Secondary VPC Instance - us-west-2</h1>
<p>Private IP: 10.1.1.x</p>
<p>Region: us-west-2</p>
```

This confirms HTTP traffic flows over the peering connection! ✅

---

### Test 8: Traceroute to Verify Path

While SSH'd into Primary instance:
```bash
sudo apt-get install -y traceroute
traceroute <SECONDARY_PRIVATE_IP>
```

**Expected:** Should show direct path with minimal hops (typically 2-3 hops)

---

### Test 9: Network Performance Test

Install iperf3 on both instances:
```bash
# On Secondary instance
sudo apt-get install -y iperf3
iperf3 -s
```

On Primary instance:
```bash
sudo apt-get install -y iperf3
iperf3 -c <SECONDARY_PRIVATE_IP> -t 10
```

This tests actual bandwidth between VPCs!

---

## Monitoring & Verification via Console

### View VPC Flow Logs (Optional)

1. Go to **VPC → Your VPCs**
2. Select **Primary-VPC**
3. Click **"Flow logs"** tab
4. Click **"Create flow log"**
5. **Configuration:**
   ```
   Filter:                  All (Accept and Reject)
   Destination:             Send to CloudWatch Logs
   Log group name:          /aws/vpc/flowlogs
   IAM role:                (Create new role)
   ```
6. Click **"Create flow log"**

**View Logs:**
- Go to **CloudWatch → Log groups**
- Click on `/aws/vpc/flowlogs`
- Examine traffic patterns

---

### View VPC Peering Metrics

1. Go to **VPC → Peering Connections**
2. Click on your peering connection
3. Click **"Monitoring"** tab
4. View metrics:
   - Bytes In
   - Bytes Out
   - Packets In
   - Packets Out

---

## Advanced Configuration (Optional)

### Enable VPC Peering DNS Resolution

This allows instances to resolve each other's DNS names.

**In us-east-1:**
1. Go to **VPC → Peering Connections**
2. Select your peering connection
3. Click **"Actions"** → **"Edit DNS settings"**
4. Check: **"Allow DNS resolution from accepter VPC to this VPC"** ☑️
5. Click **"Save changes"**

**In us-west-2:**
1. Go to **VPC → Peering Connections**
2. Select the same peering connection
3. Click **"Actions"** → **"Edit DNS settings"**
4. Check: **"Allow DNS resolution from requester VPC to this VPC"** ☑️
5. Click **"Save changes"**

---

### Add Tags for Better Organization

**Tag your resources:**

1. Select any resource (VPC, Subnet, etc.)
2. Click **"Tags"** tab
3. Click **"Manage tags"**
4. Add tags:
   ```
   Key: Environment     Value: Demo
   Key: Project         Value: VPC-Peering-Tutorial
   Key: Owner           Value: YourName
   Key: CostCenter      Value: Training
   ```
5. Click **"Save"**

**Benefit:** Easier filtering, cost allocation, and resource management

---

## Next Steps & Extensions

To enhance this demo and learn more, follow these detailed step-by-step guides:

---

## Extension 1: Add Private Subnets

### Overview
Private subnets contain resources that should NOT be directly accessible from the internet (databases, application servers, etc.).

### Architecture Addition
```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24)   ← Already exists
│   └── EC2 with Public IP
└── Private Subnet (10.0.2.0/24)  ← New
    └── EC2without Public IP (uses NAT for outbound)
```

### Step-by-Step Instructions

#### Step 1.1: Create Private Subnet in Primary VPC (us-east-1)

1. **Switch to us-east-1**
2. Go to **VPC → Subnets**
3. Click **"Create subnet"**
4. **Configuration:**
   ```
   VPC ID:                     Primary-VPC
   Subnet name:                Primary-Private-Subnet
   Availability Zone:          us-east-1a
   IPv4 CIDR block:            10.0.2.0/24
   ```
5. Click **"Create subnet"**

#### Step 1.2: Verify Auto-Assign Public IP is DISABLED

1. Click on **"Primary-Private-Subnet"**
2. Check subnet settings
3. **"Auto-assign public IPv4 address"** should be **"No"** ✅
4. If "Yes", click **"Actions"** → **"Edit subnet settings"** → Uncheck the box

#### Step 1.3: Create Private Route Table

1. Go to **VPC → Route Tables**
2. Click **"Create route table"**
3. **Configuration:**
   ```
   Name:                       Primary-Private-Route-Table
   VPC:                        Primary-VPC
   ```
4. Click **"Create route table"**

#### Step 1.4: Associate Private Subnet with Private Route Table

1. Click on **"Primary-Private-Route-Table"**
2. Scroll to **"Subnet Associations"**
3. Click **"Edit subnet associations"**
4. Check **"Primary-Private-Subnet"** ☑️
5. Click **"Save associations"**

#### Step 1.5: Add Route to Secondary VPC (for peering)

1. Still in **"Primary-Private-Route-Table"** details
2. Scroll to **"Routes"** section
3. Click **"Edit routes"**
4. Click **"Add route"**
5. **Configuration:**
   ```
   Destination:                10.1.0.0/16
   Target:                     Peering Connection → (select your peering)
   ```
6. Click **"Save changes"**

#### Step 1.6: Create Private Subnet in Secondary VPC (us-west-2)

1. **Switch to us-west-2**
2. Go to **VPC → Subnets**
3. Click **"Create subnet"**
4. **Configuration:**
   ```
   VPC ID:                     Secondary-VPC
   Subnet name:                Secondary-Private-Subnet
   Availability Zone:          us-west-2a
   IPv4 CIDR block:            10.1.2.0/24
   ```
5. Click **"Create subnet"**

#### Step 1.7: Create Private Route Table for Secondary VPC

1. Go to **VPC → Route Tables**
2. Click **"Create route table"**
3. **Configuration:**
   ```
   Name:                       Secondary-Private-Route-Table
   VPC:                        Secondary-VPC
   ```
4. Click **"Create route table"**

#### Step 1.8: Associate and Configure Routes

1. Associate **"Secondary-Private-Subnet"** with **"Secondary-Private-Route-Table"**
2. Add route to Primary VPC:
   ```
   Destination:                10.0.0.0/16
   Target:                     Peering Connection
   ```

#### Step 1.9: Test Private Subnet

1. Launch an EC2 instance in **Primary-Private-Subnet**
2. Use same security group and AMI as before
3. **Note:** No public IP will be assigned
4. To access, SSH through the public instance:
   ```bash
   # From local → Public instance
   ssh -i key.pem ubuntu@<PUBLIC_INSTANCE_IP>
   
   # From public instance → Private instance
   ssh ubuntu@<PRIVATE_INSTANCE_PRIVATE_IP>
   ```

**Learning Outcome:** ✅ Understanding public vs private subnet architecture

---

## Extension 2: Implement NAT Gateways

### Overview
NAT Gateway allows private subnet instances to access the internet for updates/downloads while remaining unreachable from the internet.

### Architecture
```
Private Instance → NAT Gateway (in public subnet) → Internet Gateway → Internet
```

### Step-by-Step Instructions

#### Step 2.1: Allocate Elastic IP for NAT Gateway

1. **Switch to us-east-1**
2. Go to **VPC → Elastic IPs**
3. Click **"Allocate Elastic IP address"**
4. **Configuration:**
   ```
   Network Border Group:       us-east-1 (default)
   Public IPv4 address pool:   Amazon's pool of IPv4 addresses
   ```
5. Click **"Allocate"**
6. **Save the Elastic IP** (e.g., 54.x.x.x)

#### Step 2.2: Create NAT Gateway

1. Go to **VPC → NAT Gateways**
2. Click **"Create NAT gateway"**
3. **Configuration:**
   ```
   Name:                       Primary-NAT-Gateway
   Subnet:                     Primary-Subnet (public subnet!)
   Connectivity type:          Public
   Elastic IP allocation ID:   (select the EIP you just created)
   ```
4. Click **"Create NAT gateway"**
5. **Wait 2-3 minutes** for status to become **"Available"**

#### Step 2.3: Update Private Route Table

1. Go to **VPC → Route Tables**
2. Click on **"Primary-Private-Route-Table"**
3. Scroll to **"Routes"** section
4. Click **"Edit routes"**
5. Click **"Add route"**
6. **Configuration:**
   ```
   Destination:                0.0.0.0/0
   Target:                     NAT Gateway → Primary-NAT-Gateway
   ```
7. Click **"Save changes"**

#### Step 2.4: Test NAT Gateway

1. SSH into your **public instance** in Primary VPC
2. SSH from public to **private instance**:
   ```bash
   ssh ubuntu@<PRIVATE_INSTANCE_IP>
   ```
3. Test internet connectivity from private instance:
   ```bash
   ping -c 4 8.8.8.8
   curl https://www.google.com
   sudo apt-get update
   ```

**Expected:** ✅ Private instance can reach internet but has no public IP

#### Step 2.5: Repeat for Secondary VPC (us-west-2)

1. **Switch to us-west-2**
2. Allocate Elastic IP
3. Create NAT Gateway in **Secondary-Subnet** (public subnet)
4. Update **Secondary-Private-Route-Table** with NAT Gateway route

**Cost Warning:** NAT Gateway costs ~$0.045/hour + data transfer charges

**Learning Outcome:** ✅ Secure outbound internet access for private resources

---

## Extension 3: Add VPC Flow Logs

### Overview
VPC Flow Logs capture IP traffic information going to/from network interfaces in your VPC.

### Step-by-Step Instructions

#### Step 3.1: Create CloudWatch Log Group

1. Search for **"CloudWatch"** in the AWS Console
2. Left sidebar → **"Logs"** → **"Log groups"**
3. Click **"Create log group"**
4. **Configuration:**
   ```
   Log group name:             /aws/vpc/primary-flowlogs
   Retention setting:          1 week (or as needed)
   ```
5. Click **"Create"**

#### Step 3.2: Create IAM Role for Flow Logs

1. Search for **"IAM"** in AWS Console
2. Left sidebar → **"Roles"**
3. Click **"Create role"**
4. **Select trusted entity:**
   ```
   Trusted entity type:        AWS service
   Use case:                   VPC Flow Logs
   ```
5. Click **"Next"**
6. **Permissions:** (automatically attached policy shown)
7. Click **"Next"**
8. **Role details:**
   ```
   Role name:                  VPCFlowLogsRole
   Description:                Allows VPC to publish flow logs to CloudWatch
   ```
9. Click **"Create role"**

#### Step 3.3: Enable Flow Logs on Primary VPC

1. Go to **VPC → Your VPCs**
2. Click on **"Primary-VPC"**
3. Click **"Flow logs"** tab
4. Click **"Create flow log"**
5. **Configuration:**
   ```
   Name:                       Primary-VPC-FlowLog
   Filter:                     All (Accept and Reject)
   Maximum aggregation interval: 1 minute
   Destination:                Send to CloudWatch Logs
   Destination log group:      /aws/vpc/primary-flowlogs
   IAM role:                   VPCFlowLogsRole
   Format:                     AWS default format
   ```
6. Click **"Create flow log"**

#### Step 3.4: Generate Some Traffic

1. SSH into your Primary instance
2. Ping the Secondary instance:
   ```bash
   ping -c 20 <SECONDARY_PRIVATE_IP>
   ```
3. Make HTTP requests:
   ```bash
   curl http://<SECONDARY_PRIVATE_IP>
   ```

#### Step 3.5: View Flow Logs in CloudWatch

1. Go to **CloudWatch → Logs → Log groups**
2. Click on **"/aws/vpc/primary-flowlogs"**
3. Click on any **Log stream** (named by network interface ID)
4. **Examine log entries:**
   ```
   2 123456789012 eni-xxxxxxxx 10.0.1.5 10.1.1.8 0 0 1 4 336 1622505600 1622505660 ACCEPT OK
   ```

#### Step 3.6: Understanding Flow Log Fields

```
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes start end action log-status
```

**Key Fields:**
- **srcaddr:** Source IP (your instance)
- **dstaddr:** Destination IP (peer instance)
- **action:** ACCEPT or REJECT
- **packets/bytes:** Traffic volume

#### Step 3.7: Create CloudWatch Insights Query

1. In **CloudWatch Logs**
2. Click **"Logs Insights"**
3. Select log group: **"/aws/vpc/primary-flowlogs"**
4. Use this query:
   ```sql
   fields @timestamp, srcAddr, dstAddr, action, packets
   | filter action = "REJECT"
   | sort @timestamp desc
   | limit 20
   ```
5. Click **"Run query"**
6. **Result:** See all rejected traffic attempts

#### Step 3.8: Set Up Flow Log Alerts (Optional)

1. Go to **CloudWatch → Alarms**
2. Click **"Create alarm"**
3. Select metric → **Logs** → **Log group metrics**
4. Create alarm for rejected traffic spikes

**Learning Outcome:** ✅ Network traffic visibility and security monitoring

---

## Extension 4: Create Additional EC2 Instances

### Overview
Deploy multiple instances to simulate real-world application architecture.

### Architecture
```
Primary VPC:
├── Web Server 1 (public subnet)
├── Web Server 2 (public subnet)
└── Database Server (private subnet)
```

### Step-by-Step Instructions

#### Step 4.1: Launch Second Web Server

1. **Switch to us-east-1**
2. Go to **EC2 → Instances**
3. Click **"Launch instances"**
4. **Configuration:**
   ```
   Name:                       Primary-Web-Server-2
   AMI:                        Ubuntu 24.04 LTS
   Instance type:              t2.micro
   Key pair:                   vpc-peering-demo-east
   Network:                    Primary-VPC
   Subnet:                     Primary-Subnet (public)
   Auto-assign public IP:      Enable
   Security group:             Primary-VPC-SG
   ```
5. **User data:**
   ```bash
   #!/bin/bash
   apt-get update -y
   apt-get install -y apache2
   systemctl start apache2
   systemctl enable apache2
   echo "<h1>Web Server 2 - Primary VPC</h1>" > /var/www/html/index.html
   echo "<p>Instance: $(hostname)</p>" >> /var/www/html/index.html
   ```
6. Click **"Launch instance"**

#### Step 4.2: Launch Database Server in Private Subnet

1. Click **"Launch instances"**
2. **Configuration:**
   ```
   Name:                       Primary-Database-Server
   AMI:                        Ubuntu 24.04 LTS
   Instance type:              t2.micro
   Key pair:                   vpc-peering-demo-east
   Network:                    Primary-VPC
   Subnet:                     Primary-Private-Subnet
   Auto-assign public IP:      Disable
   Security group:             (create new)
   ```

#### Step 4.3: Create Database Security Group

1. In the launch wizard, click **"Create security group"**
2. **Configuration:**
   ```
   Security group name:        Primary-DB-SG
   Description:                Security group for database servers
   VPC:                        Primary-VPC
   ```

3. **Inbound rules:**
   ```
   Rule 1:
   Type:                       MySQL/Aurora
   Port:                       3306
   Source:                     10.0.1.0/24 (public subnet)
   Description:                MySQL from web servers
   
   Rule 2:
   Type:                       SSH
   Port:                       22
   Source:                     10.0.1.0/24
   Description:                SSH from public subnet
   ```

4. Click **"Launch instance"**

#### Step 4.4: Install MySQL on Database Server

1. SSH to public instance:
   ```bash
   ssh -i vpc-peering-demo-east.pem ubuntu@<PUBLIC_INSTANCE_IP>
   ```

2. From public instance, SSH to database server:
   ```bash
   ssh ubuntu@<DB_PRIVATE_IP>
   ```

3. Install MySQL:
   ```bash
   sudo apt-get update
   sudo apt-get install -y mysql-server
   sudo systemctl start mysql
   sudo systemctl enable mysql
   ```

4. Configure MySQL to allow remote connections:
   ```bash
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   # Change: bind-address = 127.0.0.1
   # To:     bind-address = 0.0.0.0
   
   sudo systemctl restart mysql
   ```

#### Step 4.5: Test Multi-Tier Architecture

1. From web server, connect to database:
   ```bash
   mysql -h <DB_PRIVATE_IP> -u root -p
   ```

2. Create a test database:
   ```sql
   CREATE DATABASE testdb;
   USE testdb;
   CREATE TABLE users (id INT, name VARCHAR(50));
   INSERT INTO users VALUES (1, 'VPC Peering Test');
   SELECT * FROM users;
   ```

**Learning Outcome:** ✅ Multi-tier application architecture

---

## Extension 5: Set Up Site-to-Site VPN Connection

### Overview
Connect your VPC to an on-premise network or another cloud provider using IPsec VPN.

### Architecture
```
On-Premise Network ←→ Customer Gateway ←→ VPN Connection ←→ Virtual Private Gateway ←→ VPC
```

### Step-by-Step Instructions

#### Step 5.1: Create Virtual Private Gateway

1. **Switch to us-east-1**
2. Go to **VPC → Virtual Private Gateways**
3. Click **"Create virtual private gateway"**
4. **Configuration:**
   ```
   Name tag:                   Primary-VGW
   ASN:                        Amazon default ASN
   ```
5. Click **"Create virtual private gateway"**

#### Step 5.2: Attach VGW to VPC

1. Select the newly created **"Primary-VGW"**
2. Click **"Actions"** → **"Attach to VPC"**
3. **Configuration:**
   ```
   VPC:                        Primary-VPC
   ```
4. Click **"Attach to VPC"**
5. Wait for state to become **"attached"**

#### Step 5.3: Create Customer Gateway

1. Go to **VPC → Customer Gateways**
2. Click **"Create customer gateway"**
3. **Configuration:**
   ```
   Name:                       OnPremise-CGW
   BGP ASN:                    65000
   IP address:                 <YOUR_PUBLIC_IP>
   ```
   (Get your public IP from: https://whatismyipaddress.com)
4. Click **"Create customer gateway"**

#### Step 5.4: Create VPN Connection

1. Go to **VPC → Site-to-Site VPN Connections**
2. Click **"Create VPN connection"**
3. **Configuration:**
   ```
   Name tag:                   Primary-to-OnPrem-VPN
   Target gateway type:        Virtual private gateway
   Virtual private gateway:    Primary-VGW
   Customer gateway:           OnPremise-CGW
   Routing options:            Static
   Static IP prefixes:         192.168.1.0/24 (your on-premise network)
   Tunnel options:             (leave default)
   ```
4. Click **"Create VPN connection"**
5. **Wait 5-10 minutes** for VPN to be provisioned

#### Step 5.5: Download VPN Configuration

1. Select your VPN connection
2. Click **"Download configuration"**
3. **Configuration:**
   ```
   Vendor:                     Generic
   Platform:                   Generic
   Software:                   Vendor Agnostic
   ```
4. Click **"Download"**
5. This file contains tunnel configuration details

#### Step 5.6: Update Route Table

1. Go to **VPC → Route Tables**
2. Select **"Primary-Route-Table"**
3. Click **"Edit routes"**
4. Click **"Add route"**
5. **Configuration:**
   ```
   Destination:                192.168.1.0/24 (on-premise network)
   Target:                     Virtual Private Gateway → Primary-VGW
   ```
6. Click **"Save changes"**

#### Step 5.7: Enable Route Propagation (Optional)

1. Still in route table details
2. Scroll to **"Route propagation"** tab
3. Click **"Edit route propagation"**
4. Check **"Primary-VGW"** ☑️
5. Click **"Save"**

**Note:** This automatically adds routes learned via BGP

#### Step 5.8: Configure On-Premise Device

Use the downloaded configuration file to set up your on-premise VPN device:
- Firewall (pfSense, FortiGate, etc.)
- Router (Cisco, Juniper, etc.)
- Software VPN (strongSwan, OpenVPN, etc.)

**Learning Outcome:** ✅ Hybrid cloud connectivity

---

## Extension 6: Implement Transit Gateway

### Overview
Transit Gateway acts as a network hub, connecting multiple VPCs and on-premise networks (better than mesh peering).

### Architecture Comparison
```
Before (Mesh):                After (Hub):
VPC-A ←→ VPC-B               VPC-A ↘
VPC-A ←→ VPC-C         →              Transit Gateway → On-Premise
VPC-B ←→ VPC-C               VPC-B ↗          ↕
                             VPC-C ↗      Other VPCs
```

### Step-by-Step Instructions

#### Step 6.1: Create Transit Gateway

1. **Switch to us-east-1**
2. Go to **VPC → Transit Gateways**
3. Click **"Create transit gateway"**
4. **Configuration:**
   ```
   Name tag:                   Main-Transit-Gateway
   Description:                Hub for all VPC connectivity
   Amazon side ASN:            64512
   DNS support:                ☑️ Enable
   VPN ECMP support:           ☑️ Enable
   Default route table association: ☑️ Enable
   Default route table propagation: ☑️ Enable
   Auto accept shared attachments:  Disable
   ```
5. Click **"Create transit gateway"**
6. **Wait 3-5 minutes** for state to become **"available"**

#### Step 6.2: Create Transit Gateway Attachment for Primary VPC

1. Go to **VPC → Transit Gateway Attachments**
2. Click **"Create transit gateway attachment"**
3. **Configuration:**
   ```
   Name tag:                   Primary-VPC-Attachment
   Transit gateway ID:         Main-Transit-Gateway
   Attachment type:            VPC
   VPC ID:                     Primary-VPC
   Subnet IDs:                 Primary-Subnet (select checkbox)
   ```
4. Click **"Create transit gateway attachment"**
5. Wait for state: **"available"**

#### Step 6.3: Create Transit Gateway Attachment for Secondary VPC

**Important:** Transit Gateway must exist in same region as VPC for standard attachment

1. For cross-region, use **Transit Gateway Peering** (advanced)
2. For this example, create a third VPC in us-east-1:

**Create Third VPC:**
```
Name:                         Tertiary-VPC
CIDR:                         10.2.0.0/16
Subnet:                       10.2.1.0/24
```

3. Create attachment for Tertiary VPC following Step 6.2

#### Step 6.4: Update Route Tables

1. Go to **VPC → Route Tables**
2. Select **"Primary-Route-Table"**
3. Add routes:
   ```
   Destination:                10.2.0.0/16 (Tertiary VPC)
   Target:                     Transit Gateway → Main-Transit-Gateway
   ```

4. Repeat for Tertiary VPC route table pointing to 10.0.0.0/16

#### Step 6.5: Configure Transit Gateway Route Table

1. Go to **VPC → Transit Gateway Route Tables**
2. Select the automatically created route table
3. Click **"Routes"** tab
4. Verify routes are propagated automatically

#### Step 6.6: Test Transit Gateway Connectivity

1. Launch an instance in Tertiary VPC
2. From Primary VPC instance, ping Tertiary VPC instance:
   ```bash
   ping <TERTIARY_INSTANCE_PRIVATE_IP>
   ```

**Expected:** ✅ All VPCs can communicate through the Transit Gateway

**Cost Warning:** Transit Gateway costs $0.05/hour + data transfer

**Learning Outcome:** ✅ Centralized network hub for complex topologies

---

## Extension 7: Add Application Load Balancer

### Overview
Distribute traffic across multiple web servers for high availability.

### Architecture
```
Internet → ALB → Target Group → [Web Server 1, Web Server 2]
```

### Step-by-Step Instructions

#### Step 7.1: Create Target Group

1. **Switch to us-east-1**
2. Go to **EC2 → Target Groups**
3. Click **"Create target group"**
4. **Configuration:**
   ```
   Choose target type:         Instances
   Target group name:          Primary-Web-TG
   Protocol:                   HTTP
   Port:                       80
   VPC:                        Primary-VPC
   Protocol version:           HTTP1
   Health check protocol:      HTTP
   Health check path:          /
   ```
5. Click **"Next"**

#### Step 7.2: Register Targets

1. **Select instances:**
   - Check **"Primary-VPC-Instance"** ☑️
   - Check **"Primary-Web-Server-2"** ☑️ (if created in Extension 4)
2. **Ports:** 80 (default)
3. Click **"Include as pending below"**
4. Click **"Create target group"**

#### Step 7.3: Create Application Load Balancer

1. Go to **EC2 → Load Balancers**
2. Click **"Create load balancer"**
3. Select **"Application Load Balancer"**
4. Click **"Create"**

#### Step 7.4: Configure Load Balancer

**Basic configuration:**
```
Load balancer name:           Primary-ALB
Scheme:                       Internet-facing
IP address type:              IPv4
```

**Network mapping:**
```
VPC:                          Primary-VPC
Mappings:                     us-east-1a (Primary-Subnet)
                              us-east-1b (create another subnet if needed)
```

#### Step 7.5: Configure Security Group

1. **Create new security group** or select existing
2. **Inbound rules:**
   ```
   Type:                       HTTP
   Port:                       80
   Source:                     0.0.0.0/0
   Description:                HTTP from anywhere
   ```

#### Step 7.6: Configure Listeners and Routing

```
Listeners:
  Protocol:                   HTTP
  Port:                       80
  Default action:             Forward to Primary-Web-TG
```

Click **"Create load balancer"**

#### Step 7.7: Wait for Provisioning

1. Wait 2-3 minutes
2. State should change to **"active"**
3. Copy the **DNS name** (e.g., Primary-ALB-123456789.us-east-1.elb.amazonaws.com)

#### Step 7.8: Test Load Balancer

1. Open browser
2. Navigate to: `http://PRIMARY-ALB-DNS-NAME`
3. Refresh multiple times
4. You should see responses from different web servers

#### Step 7.9: View Target Health

1. Go to **EC2 → Target Groups**
2. Click on **"Primary-Web-TG"**
3. Click **"Targets"** tab
4. **Health status** should be **"healthy"** for all instances

**Learning Outcome:** ✅ High availability and load distribution

---

## Extension 8: Implement Network ACLs (NACLs)

### Overview
Network ACLs are stateless firewalls at the subnet level (additional security layer).

### Security Layers
```
Internet → NACL → Security Group → Instance
         (subnet)    (instance)
```

### Step-by-Step Instructions

#### Step 8.1: Create Custom NACL

1. **Switch to us-east-1**
2. Go to **VPC → Network ACLs**
3. Click **"Create network ACL"**
4. **Configuration:**
   ```
   Name:                       Primary-Custom-NACL
   VPC:                        Primary-VPC
   ```
5. Click **"Create network ACL"**

#### Step 8.2: Configure Inbound Rules

1. Click on **"Primary-Custom-NACL"**
2. Click **"Inbound rules"** tab
3. Click **"Edit inbound rules"**
4. Click **"Add new rule"** multiple times:

**Rule 100: Allow SSH**
```
Rule number:                  100
Type:                         SSH (22)
Source:                       0.0.0.0/0
Allow/Deny:                   Allow
```

**Rule 110: Allow HTTP**
```
Rule number:                  110
Type:                         HTTP (80)
Source:                       0.0.0.0/0
Allow/Deny:                   Allow
```

**Rule 120: Allow Return Traffic (Ephemeral Ports)**
```
Rule number:                  120
Type:                         Custom TCP
Port range:                   1024-65535
Source:                       0.0.0.0/0
Allow/Deny:                   Allow
```

**Rule 130: Allow ICMP from Peer VPC**
```
Rule number:                  130
Type:                         All ICMP - IPv4
Source:                       10.1.0.0/16
Allow/Deny:                   Allow
```

**Rule * (Default): Deny All**
```
Rule number:                  *
Type:                         All traffic
Source:                       0.0.0.0/0
Allow/Deny:                   Deny
```

5. Click **"Save changes"**

#### Step 8.3: Configure Outbound Rules

1. Click **"Outbound rules"** tab
2. Click **"Edit outbound rules"**

**Rule 100: Allow All Outbound**
```
Rule number:                  100
Type:                         All traffic
Destination:                  0.0.0.0/0
Allow/Deny:                   Allow
```

3. Click **"Save changes"**

#### Step 8.4: Associate NACL with Subnet

1. Still viewing **"Primary-Custom-NACL"**
2. Click **"Subnet associations"** tab
3. Click **"Edit subnet associations"**
4. Check **"Primary-Subnet"** ☑️
5. Click **"Save changes"**

#### Step 8.5: Test NACL Rules

1. SSH into Primary instance (should work - Rule 100 allows)
2. Try to access from disallowed source (should fail)
3. Ping from Secondary VPC (should work - Rule 130 allows)

#### Step 8.6: Add Deny Rule (Testing)

1. Edit inbound rules
2. Add **Rule 50** (processed before Rule 100):
   ```
   Rule number:                50
   Type:                       SSH (22)
   Source:                     <YOUR_IP>/32
   Allow/Deny:                 Deny
   ```
3. Try to SSH → Should be **blocked** ❌
4. Remove Rule 50 to restore access

**Key Difference: NACL vs Security Group**
- **NACL:** Stateless (must allow return traffic explicitly)
- **Security Group:** Stateful (return traffic automatic)

**Learning Outcome:** ✅ Defense-in-depth network security

---

## Extension 9: Set Up CloudWatch Alarms

### Overview
Proactive monitoring with automated alerts for your infrastructure.

### Step-by-Step Instructions

#### Step 9.1: Create SNS Topic for Notifications

1. Search for **"SNS"** in AWS Console
2. Click **"Topics"** in left sidebar
3. Click **"Create topic"**
4. **Configuration:**
   ```
   Type:                       Standard
   Name:                       VPC-Alerts
   Display name:               VPC Alerts
   ```
5. Click **"Create topic"**

#### Step 9.2: Create Email Subscription

1. Click on **"VPC-Alerts"** topic
2. Click **"Create subscription"**
3. **Configuration:**
   ```
   Protocol:                   Email
   Endpoint:                   your-email@example.com
   ```
4. Click **"Create subscription"**
5. **Check your email** and click the confirmation link

#### Step 9.3: Create CPU Utilization Alarm

1. Go to **CloudWatch → Alarms → All alarms**
2. Click **"Create alarm"**
3. Click **"Select metric"**
4. Navigate to: **EC2 → Per-Instance Metrics**
5. Find your **Primary-VPC-Instance**
6. Select **"CPUUtilization"** metric
7. Click **"Select metric"**

#### Step 9.4: Configure Alarm Conditions

```
Statistic:                    Average
Period:                       5 minutes
Threshold type:               Static
Whenever CPUUtilization is:   Greater than 80
```

Click **"Next"**

#### Step 9.5: Configure Actions

```
Alarm state trigger:          In alarm
Send notification to:         VPC-Alerts (select your SNS topic)
```

Click **"Next"**

#### Step 9.6: Name and Create Alarm

```
Alarm name:                   Primary-Instance-High-CPU
Description:                  Alert when CPU exceeds 80%
```

Click **"Next"** → **"Create alarm"**

#### Step 9.7: Create Data Transfer Alarm

1. Create another alarm
2. Metric: **VPC → VPC Metrics → BytesOut**
3. **Configuration:**
   ```
   Threshold:                  Greater than 1000000000 (1GB)
   Period:                     1 hour
   SNS topic:                  VPC-Alerts
   Alarm name:                 High-Data-Transfer
   ```

#### Step 9.8: Create Peering Connection Alarm

1. Metric: **VPC → VPC Peering Connection Metrics**
2. Select your peering connection
3. Metric: **BytesOut**
4. **Configuration:**
   ```
   Threshold:                  Greater than 500000000 (500MB)
   Period:                     1 hour
   Alarm name:                 High-Peering-Traffic
   ```

#### Step 9.9: Test Alarm

Generate high CPU on instance:
```bash
# SSH into instance
stress --cpu 4 --timeout 300s

# Or if stress not installed:
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &

# Kill processes after testing:
killall dd
```

Wait 5 minutes - you should receive an email alert!

#### Step 9.10: View Alarm History

1. Go to **CloudWatch → Alarms**
2. Click on alarm name
3. View **"History"** tab to see state changes

**Learning Outcome:** ✅ Proactive monitoring and incident response

---

## Extension 10: Create Route 53 Private Hosted Zone

### Overview
Internal DNS resolution for resources in your VPCs (use friendly names instead of IPs).

### Architecture
```
app.internal.vpc → Route 53 Private Hosted Zone → 10.0.1.5 (Instance)
```

### Step-by-Step Instructions

#### Step 10.1: Create Private Hosted Zone

1. Search for **"Route 53"** in AWS Console
2. Click **"Hosted zones"** in left sidebar
3. Click **"Create hosted zone"**
4. **Configuration:**
   ```
   Domain name:                internal.vpc
   Description:                Private DNS for VPC resources
   Type:                       Private hosted zone
   VPCs to associate:
     Region:                   us-east-1
     VPC ID:                   Primary-VPC
   ```
5. Click **"Create hosted zone"**

#### Step 10.2: Associate Additional VPC (Secondary)

1. Click on **"internal.vpc"** hosted zone
2. In the right panel, click **"Edit"** under "VPCs"
3. Click **"Associate VPC with hosted zone"**
4. **Configuration:**
   ```
   Region:                     us-west-2
   VPC ID:                     Secondary-VPC
   ```
5. Click **"Associate"**

#### Step 10.3: Create DNS Record for Primary Instance

1. Still in **"internal.vpc"** hosted zone
2. Click **"Create record"**
3. **Configuration:**
   ```
   Record name:                web1
   Record type:                A - Routes traffic to IPv4
   Value:                      <PRIMARY_INSTANCE_PRIVATE_IP>
   TTL:                        300
   Routing policy:             Simple routing
   ```
4. Click **"Create records"**

#### Step 10.4: Create DNS Record for Secondary Instance

1. Click **"Create record"**
2. **Configuration:**
   ```
   Record name:                web2
   Record type:                A
   Value:                      <SECONDARY_INSTANCE_PRIVATE_IP>
   TTL:                        300
   ```
3. Click **"Create records"**

#### Step 10.5: Create CNAME for Database

1. If you created a database server (Extension 4):
2. Create record:
   ```
   Record name:                db
   Record type:                A
   Value:                      <DB_INSTANCE_PRIVATE_IP>
   ```

#### Step 10.6: Test DNS Resolution

1. SSH into Primary instance
2. Test DNS resolution:
   ```bash
   # Should resolve to private IP
   nslookup web1.internal.vpc
   nslookup web2.internal.vpc
   nslookup db.internal.vpc
   
   # Ping using DNS name
   ping -c 4 web2.internal.vpc
   
   # HTTP request using DNS name
   curl http://web2.internal.vpc
   ```

**Expected Output:**
```
web2.internal.vpc resolves to 10.1.1.x
PING successful
HTTP response received
```

#### Step 10.7: Create Alias Record for Load Balancer

If you created ALB (Extension 7):

1. Create record:
   ```
   Record name:                app
   Record type:                A - Routes to IPv4
   Alias:                      ☑️ Yes
   Alias target:               Alias to Application Load Balancer
                               → us-east-1
                               → (select your ALB)
   ```
2. Test:
   ```bash
   curl http://app.internal.vpc
   ```

#### Step 10.8: Enable DNS Logging (Optional)

1. In hosted zone details
2. Click **"Configure query logging"**
3. Select CloudWatch log group
4. Monitor DNS queries

**Learning Outcome:** ✅ Service discovery and friendly DNS naming

---

---

## Additional Resources

### Official AWS Documentation
- [AWS VPC Peering Guide](https://docs.aws.amazon.com/vpc/latest/peering/)
- [VPC Peering Basics](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html)
- [VPC Peering Scenarios](https://docs.aws.amazon.com/vpc/latest/peering/peering-scenarios.html)
- [Cross-Region VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html)

### Best Practices & Whitepapers
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Network Security Best Practices](https://d1.awsstatic.com/whitepapers/Security/Networking_Security_Whitepaper.pdf)

### Learning Resources
- [AWS VPC Workshop](https://catalog.workshops.aws/networking/en-US)
- [AWS Networking Fundamentals](https://aws.amazon.com/training/course-descriptions/networking/)
- [AWS re:Invent VPC Sessions](https://www.youtube.com/c/AWSEventsChannel)

### Community & Forums
- [AWS Forums - VPC](https://forums.aws.amazon.com/forum.jspa?forumID=58)
- [Stack Overflow - AWS VPC Tag](https://stackoverflow.com/questions/tagged/amazon-vpc)
- [AWS subreddit](https://www.reddit.com/r/aws/)

### Tools & Utilities
- [VPC Designer Tool](https://console.aws.amazon.com/vpc/) (Visual VPC builder)
- [AWS VPC Reachability Analyzer](https://console.aws.amazon.com/vpc/home#ReachabilityAnalyzer)
- [AWS Network Manager](https://console.aws.amazon.com/networkmanager/)

---

## Frequently Asked Questions (FAQ)

### Q1: Can I peer VPCs in the same region?
**A:** Yes! Same-region VPC peering is supported and has **no data transfer charges**.

### Q2: Can I peer VPCs in different AWS accounts?
**A:** Yes! Cross-account VPC peering requires:
1. Accepter account ID when creating peering
2. Manual acceptance from the other account
3. Proper IAM permissions

### Q3: How many VPC peering connections can I have?
**A:** Maximum of **125 active peering connections per VPC**.

### Q4: Does VPC peering work with IPv6?
**A:** Yes! VPC peering supports both IPv4 and IPv6 traffic.

### Q5: Can I modify a peering connection after creation?
**A:** Limited modifications:
- Can enable/disable DNS resolution
- Cannot change VPCs involved
- Must delete and recreate to change VPCs

### Q6: What happens if CIDR blocks overlap?
**A:** Peering connection **will fail**. Cannot peer VPCs with overlapping CIDR blocks.

### Q7: Is VPC peering encrypted?
**A:** Traffic is **isolated** but not encrypted by default. Use TLS/SSL at application layer for encryption.

### Q8: Can I use Security Group IDs from peer VPC?
**A:** **No** for cross-region peering. **Yes** for same-region peering (same account or different account).

### Q9: Does peering affect my internet bandwidth?
**A:** No, peering uses AWS backbone network, separate from internet gateway traffic.

### Q10: How do I troubleshoot peering connectivity?
**A:** Use **VPC Reachability Analyzer**:
1. Go to **VPC → Reachability Analyzer**
2. Create analysis path
3. Run analysis
4. Review findings

---

## Certification & Exam Tips

### AWS Certified Solutions Architect

**Key Exam Topics:**
- ✅ VPC peering vs Transit Gateway vs PrivateLink
- ✅ Non-transitive nature of peering
- ✅ Cross-region vs same-region peering
- ✅ CIDR block planning and overlap prevention
- ✅ Peering limitations and constraints

**Common Exam Scenarios:**
1. "Company needs to connect 10+ VPCs" → **Transit Gateway**, not peering
2. "Private connectivity without overlapping IPs" → **VPC Peering**
3. "Access S3 privately from another VPC" → **VPC Endpoint**, not peering
4. "Transitive routing required" → **Transit Gateway**, not peering

---

## Glossary

| Term | Definition |
|------|------------|
| **VPC** | Virtual Private Cloud - Isolated virtual network in AWS |
| **CIDR** | Classless Inter-Domain Routing - IP address range notation |
| **IGW** | Internet Gateway - Connects VPC to the internet |
| **Peering** | Network connection between two VPCs |
| **Requester** | VPC initiating the peering connection |
| **Accepter** | VPC receiving and accepting the peering request |
| **Route Table** | Set of rules (routes) that determine traffic direction |
| **Security Group** | Virtual firewall for EC2 instances |
| **NACL** | Network Access Control List - Subnet-level firewall |
| **AMI** | Amazon Machine Image - Template for EC2 instance |
| **User Data** | Script that runs when EC2 instance launches |
| **Private IP** | Internal IP address (not routable on internet) |
| **Public IP** | Internet-routable IP address |
| **Subnet** | Segment of VPC CIDR block |

---

**Document Created:** January 29, 2026  
**Last Updated:** January 30, 2026  
**Course:** 30 Days of AWS with Terraform  
**Day:** 15 - VPC Peering Mini Project  
**Interface:** AWS Management Console (GUI)  
**Version:** 2.0
