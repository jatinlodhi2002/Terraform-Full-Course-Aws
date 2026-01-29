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

**Document Created:** January 29, 2026  
**Course:** 30 Days of AWS with Terraform  
**Day:** 15 - VPC Peering Mini Project  
**Interface:** AWS Management Console (GUI)
