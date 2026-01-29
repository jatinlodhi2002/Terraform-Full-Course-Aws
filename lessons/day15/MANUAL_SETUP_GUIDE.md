# Day 15: VPC Peering - Complete Manual Setup Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture Understanding](#architecture-understanding)
4. [Manual Step-by-Step Setup](#manual-step-by-step-setup)
5. [Testing Connectivity](#testing-connectivity)
6. [Troubleshooting](#troubleshooting)
7. [Cleanup](#cleanup)

---

## Overview

This guide provides **detailed, manual steps** to deploy AWS VPC Peering across two regions (us-east-1 and us-west-2) without using Terraform. You will create:

- **2 VPCs** in different regions
- **2 Subnets** (one per VPC)
- **2 Internet Gateways**
- **VPC Peering Connection** between regions
- **2 EC2 Instances** for connectivity testing

**Total Estimated Time:** 45-60 minutes

---

## Prerequisites

Before you begin, ensure you have:

1. **AWS Account** with appropriate IAM permissions
2. **AWS CLI** installed and configured
   ```bash
   aws --version
   aws configure
   ```
3. **SSH Client** (built-in on Linux/Mac, use PuTTY or Git Bash on Windows)
4. **Browser** to access AWS Console
5. **Text Editor** for notes
6. **EC2 Key Pairs** created in both regions

### Create EC2 Key Pairs

**For us-east-1:**
```bash
aws ec2 create-key-pair \
  --key-name vpc-peering-demo-east \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > vpc-peering-demo-east.pem

chmod 400 vpc-peering-demo-east.pem
```

**For us-west-2:**
```bash
aws ec2 create-key-pair \
  --key-name vpc-peering-demo-west \
  --region us-west-2 \
  --query 'KeyMaterial' \
  --output text > vpc-peering-demo-west.pem

chmod 400 vpc-peering-demo-west.pem
```

---

## Architecture Understanding

```
┌────────────────────────────────────────────────────────────────┐
│                         AWS Account                             │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Region: us-east-1                    Region: us-west-2        │
│  ┌──────────────────────────┐         ┌──────────────────────┐  │
│  │  Primary VPC             │         │  Secondary VPC       │  │
│  │  CIDR: 10.0.0.0/16       │         │  CIDR: 10.1.0.0/16   │  │
│  │                          │         │                      │  │
│  │  ┌────────────────────┐  │         │  ┌────────────────┐   │  │
│  │  │ Subnet             │  │         │  │ Subnet         │   │  │
│  │  │ 10.0.1.0/24        │  │         │  │ 10.1.1.0/24    │   │  │
│  │  │                    │  │         │  │                │   │  │
│  │  │ ┌────────────────┐ │  │         │  │ ┌────────────┐  │   │  │
│  │  │ │ EC2 Instance   │ │  │         │  │ │ EC2 Instance   │   │  │
│  │  │ │ 10.0.1.x       │ │  │         │  │ │ 10.1.1.x    │   │  │
│  │  │ └────────────────┘ │  │         │  │ └────────────┘   │  │
│  │  └────────────────────┘  │         │  └────────────────┘   │  │
│  │                          │         │                      │  │
│  │  IGW: Internet Gateway   │         │  IGW: Internet       │  │
│  └──────────────────────────┘         │      Gateway         │  │
│              │                        │                      │  │
│              │          ┌─────────────┴──────────────┐       │  │
│              │          │    VPC Peering Connection   │       │  │
│              └──────────┤    pcx-xxxxxxxx            │       │  │
│                         │    Status: active          │       │  │
│                         └────────────────────────────┘       │  │
│                                                                  │
└────────────────────────────────────────────────────────────────┘
```

**Key Concept:** VPC Peering allows resources to communicate using **private IP addresses** without routing traffic through the internet.

---

## Manual Step-by-Step Setup

### STEP 1: Create Primary VPC (us-east-1)

#### 1.1 Create VPC
```bash
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --region us-east-1 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Primary-VPC},{Key=Environment,Value=Demo}]'
```

**Save the VPC ID** (output: `VpcId`). Example: `vpc-xxxxxxxxx`

```bash
# Store it in a variable for later use
export PRIMARY_VPC_ID="vpc-xxxxxxxxx"
```

#### 1.2 Enable DNS Hostname Resolution
```bash
aws ec2 modify-vpc-attribute \
  --vpc-id $PRIMARY_VPC_ID \
  --enable-dns-hostnames \
  --region us-east-1

aws ec2 modify-vpc-attribute \
  --vpc-id $PRIMARY_VPC_ID \
  --enable-dns-support \
  --region us-east-1
```

---

### STEP 2: Create Secondary VPC (us-west-2)

#### 2.1 Create VPC
```bash
aws ec2 create-vpc \
  --cidr-block 10.1.0.0/16 \
  --region us-west-2 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Secondary-VPC},{Key=Environment,Value=Demo}]'
```

**Save the VPC ID** (example: `vpc-yyyyyyyyy`)

```bash
export SECONDARY_VPC_ID="vpc-yyyyyyyyy"
```

#### 2.2 Enable DNS Hostname Resolution
```bash
aws ec2 modify-vpc-attribute \
  --vpc-id $SECONDARY_VPC_ID \
  --enable-dns-hostnames \
  --region us-west-2

aws ec2 modify-vpc-attribute \
  --vpc-id $SECONDARY_VPC_ID \
  --enable-dns-support \
  --region us-west-2
```

---

### STEP 3: Create Subnets

#### 3.1 Create Primary Subnet (us-east-1)
```bash
aws ec2 create-subnet \
  --vpc-id $PRIMARY_VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --region us-east-1 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Primary-Subnet}]'
```

**Save the Subnet ID** (example: `subnet-aaaaaa`)

```bash
export PRIMARY_SUBNET_ID="subnet-aaaaaa"
```

#### 3.2 Enable Auto-assign Public IP for Primary Subnet
```bash
aws ec2 modify-subnet-attribute \
  --subnet-id $PRIMARY_SUBNET_ID \
  --map-public-ip-on-launch \
  --region us-east-1
```

#### 3.3 Create Secondary Subnet (us-west-2)
```bash
aws ec2 create-subnet \
  --vpc-id $SECONDARY_VPC_ID \
  --cidr-block 10.1.1.0/24 \
  --availability-zone us-west-2a \
  --region us-west-2 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Secondary-Subnet}]'
```

**Save the Subnet ID** (example: `subnet-bbbbbb`)

```bash
export SECONDARY_SUBNET_ID="subnet-bbbbbb"
```

#### 3.4 Enable Auto-assign Public IP for Secondary Subnet
```bash
aws ec2 modify-subnet-attribute \
  --subnet-id $SECONDARY_SUBNET_ID \
  --map-public-ip-on-launch \
  --region us-west-2
```

---

### STEP 4: Create and Attach Internet Gateways

#### 4.1 Create Primary Internet Gateway
```bash
aws ec2 create-internet-gateway \
  --region us-east-1 \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Primary-IGW}]'
```

**Save the IGW ID** (example: `igw-cccccc`)

```bash
export PRIMARY_IGW_ID="igw-cccccc"
```

#### 4.2 Attach Primary IGW to Primary VPC
```bash
aws ec2 attach-internet-gateway \
  --internet-gateway-id $PRIMARY_IGW_ID \
  --vpc-id $PRIMARY_VPC_ID \
  --region us-east-1
```

#### 4.3 Create Secondary Internet Gateway
```bash
aws ec2 create-internet-gateway \
  --region us-west-2 \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Secondary-IGW}]'
```

**Save the IGW ID** (example: `igw-dddddd`)

```bash
export SECONDARY_IGW_ID="igw-dddddd"
```

#### 4.4 Attach Secondary IGW to Secondary VPC
```bash
aws ec2 attach-internet-gateway \
  --internet-gateway-id $SECONDARY_IGW_ID \
  --vpc-id $SECONDARY_VPC_ID \
  --region us-west-2
```

---

### STEP 5: Create and Configure Route Tables

#### 5.1 Create Primary Route Table
```bash
aws ec2 create-route-table \
  --vpc-id $PRIMARY_VPC_ID \
  --region us-east-1 \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Primary-Route-Table}]'
```

**Save the Route Table ID** (example: `rtb-eeeeee`)

```bash
export PRIMARY_RT_ID="rtb-eeeeee"
```

#### 5.2 Add Default Route to Primary Route Table (via Internet Gateway)
```bash
aws ec2 create-route \
  --route-table-id $PRIMARY_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $PRIMARY_IGW_ID \
  --region us-east-1
```

#### 5.3 Associate Primary Route Table with Primary Subnet
```bash
aws ec2 associate-route-table \
  --subnet-id $PRIMARY_SUBNET_ID \
  --route-table-id $PRIMARY_RT_ID \
  --region us-east-1
```

#### 5.4 Create Secondary Route Table
```bash
aws ec2 create-route-table \
  --vpc-id $SECONDARY_VPC_ID \
  --region us-west-2 \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Secondary-Route-Table}]'
```

**Save the Route Table ID** (example: `rtb-ffffff`)

```bash
export SECONDARY_RT_ID="rtb-ffffff"
```

#### 5.5 Add Default Route to Secondary Route Table (via Internet Gateway)
```bash
aws ec2 create-route \
  --route-table-id $SECONDARY_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $SECONDARY_IGW_ID \
  --region us-west-2
```

#### 5.6 Associate Secondary Route Table with Secondary Subnet
```bash
aws ec2 associate-route-table \
  --subnet-id $SECONDARY_SUBNET_ID \
  --route-table-id $SECONDARY_RT_ID \
  --region us-west-2
```

---

### STEP 6: Create VPC Peering Connection

#### 6.1 Create VPC Peering Connection (Requester Side)
```bash
aws ec2 create-vpc-peering-connection \
  --vpc-id $PRIMARY_VPC_ID \
  --peer-vpc-id $SECONDARY_VPC_ID \
  --peer-region us-west-2 \
  --region us-east-1 \
  --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=Primary-to-Secondary-Peering}]'
```

**Save the Peering Connection ID** (example: `pcx-gggggg`)

```bash
export PCX_ID="pcx-gggggg"
```

#### 6.2 Accept VPC Peering Connection (Accepter Side)
```bash
aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $PCX_ID \
  --region us-west-2
```

**Verify the status:**
```bash
aws ec2 describe-vpc-peering-connections \
  --vpc-peering-connection-ids $PCX_ID \
  --region us-east-1
```

Expected status: `active`

---

### STEP 7: Add Peering Routes to Route Tables

#### 7.1 Add Route from Primary VPC to Secondary VPC
```bash
aws ec2 create-route \
  --route-table-id $PRIMARY_RT_ID \
  --destination-cidr-block 10.1.0.0/16 \
  --vpc-peering-connection-id $PCX_ID \
  --region us-east-1
```

#### 7.2 Add Route from Secondary VPC to Primary VPC
```bash
aws ec2 create-route \
  --route-table-id $SECONDARY_RT_ID \
  --destination-cidr-block 10.0.0.0/16 \
  --vpc-peering-connection-id $PCX_ID \
  --region us-west-2
```

---

### STEP 8: Create Security Groups

#### 8.1 Create Primary Security Group
```bash
aws ec2 create-security-group \
  --group-name primary-vpc-sg \
  --description "Security group for Primary VPC instance" \
  --vpc-id $PRIMARY_VPC_ID \
  --region us-east-1 \
  --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=Primary-VPC-SG}]'
```

**Save the Security Group ID** (example: `sg-hhhhhh`)

```bash
export PRIMARY_SG_ID="sg-hhhhhh"
```

#### 8.2 Add Ingress Rules to Primary Security Group

**SSH Rule (from anywhere):**
```bash
aws ec2 authorize-security-group-ingress \
  --group-id $PRIMARY_SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1
```

**ICMP Rule (from Secondary VPC):**
```bash
aws ec2 authorize-security-group-ingress \
  --group-id $PRIMARY_SG_ID \
  --protocol icmp \
  --port -1 \
  --cidr 10.1.0.0/16 \
  --region us-east-1
```

**HTTP Rule (from Secondary VPC):**
```bash
aws ec2 authorize-security-group-ingress \
  --group-id $PRIMARY_SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 10.1.0.0/16 \
  --region us-east-1
```

#### 8.3 Create Secondary Security Group
```bash
aws ec2 create-security-group \
  --group-name secondary-vpc-sg \
  --description "Security group for Secondary VPC instance" \
  --vpc-id $SECONDARY_VPC_ID \
  --region us-west-2 \
  --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=Secondary-VPC-SG}]'
```

**Save the Security Group ID** (example: `sg-iiiiii`)

```bash
export SECONDARY_SG_ID="sg-iiiiii"
```

#### 8.4 Add Ingress Rules to Secondary Security Group

**SSH Rule (from anywhere):**
```bash
aws ec2 authorize-security-group-ingress \
  --group-id $SECONDARY_SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-west-2
```

**ICMP Rule (from Primary VPC):**
```bash
aws ec2 authorize-security-group-ingress \
  --group-id $SECONDARY_SG_ID \
  --protocol icmp \
  --port -1 \
  --cidr 10.0.0.0/16 \
  --region us-west-2
```

**HTTP Rule (from Primary VPC):**
```bash
aws ec2 authorize-security-group-ingress \
  --group-id $SECONDARY_SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 10.0.0.0/16 \
  --region us-west-2
```

---

### STEP 9: Launch EC2 Instances

#### 9.1 Get Latest Ubuntu 24.04 AMI ID for us-east-1
```bash
export PRIMARY_AMI_ID=$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text \
  --region us-east-1)

echo "Primary AMI ID: $PRIMARY_AMI_ID"
```

#### 9.2 Create User Data Script for Primary Instance
```bash
cat > /tmp/primary_userdata.sh << 'EOF'
#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Primary VPC Instance - us-east-1</h1>" > /var/www/html/index.html
echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
echo "<p>Region: us-east-1</p>" >> /var/www/html/index.html
EOF
```

#### 9.3 Launch Primary EC2 Instance
```bash
aws ec2 run-instances \
  --image-id $PRIMARY_AMI_ID \
  --instance-type t2.micro \
  --key-name vpc-peering-demo-east \
  --security-group-ids $PRIMARY_SG_ID \
  --subnet-id $PRIMARY_SUBNET_ID \
  --user-data file:///tmp/primary_userdata.sh \
  --region us-east-1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Primary-VPC-Instance}]'
```

**Save the Instance ID** (example: `i-jjjjjj`)

```bash
export PRIMARY_INSTANCE_ID="i-jjjjjj"
```

#### 9.4 Get Latest Ubuntu 24.04 AMI ID for us-west-2
```bash
export SECONDARY_AMI_ID=$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text \
  --region us-west-2)

echo "Secondary AMI ID: $SECONDARY_AMI_ID"
```

#### 9.5 Create User Data Script for Secondary Instance
```bash
cat > /tmp/secondary_userdata.sh << 'EOF'
#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Secondary VPC Instance - us-west-2</h1>" > /var/www/html/index.html
echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
echo "<p>Region: us-west-2</p>" >> /var/www/html/index.html
EOF
```

#### 9.6 Launch Secondary EC2 Instance
```bash
aws ec2 run-instances \
  --image-id $SECONDARY_AMI_ID \
  --instance-type t2.micro \
  --key-name vpc-peering-demo-west \
  --security-group-ids $SECONDARY_SG_ID \
  --subnet-id $SECONDARY_SUBNET_ID \
  --user-data file:///tmp/secondary_userdata.sh \
  --region us-west-2 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Secondary-VPC-Instance}]'
```

**Save the Instance ID** (example: `i-kkkkkk`)

```bash
export SECONDARY_INSTANCE_ID="i-kkkkkk"
```

---

### STEP 10: Verify Instances and Get Details

#### 10.1 Get Primary Instance Details
```bash
aws ec2 describe-instances \
  --instance-ids $PRIMARY_INSTANCE_ID \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].[PrivateIpAddress,PublicIpAddress,State.Name]' \
  --output table
```

**Save the Public IP and Private IP**

```bash
export PRIMARY_PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $PRIMARY_INSTANCE_ID \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

export PRIMARY_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids $PRIMARY_INSTANCE_ID \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

echo "Primary Public IP: $PRIMARY_PUBLIC_IP"
echo "Primary Private IP: $PRIMARY_PRIVATE_IP"
```

#### 10.2 Get Secondary Instance Details
```bash
aws ec2 describe-instances \
  --instance-ids $SECONDARY_INSTANCE_ID \
  --region us-west-2 \
  --query 'Reservations[0].Instances[0].[PrivateIpAddress,PublicIpAddress,State.Name]' \
  --output table
```

**Save the Public IP and Private IP**

```bash
export SECONDARY_PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $SECONDARY_INSTANCE_ID \
  --region us-west-2 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

export SECONDARY_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids $SECONDARY_INSTANCE_ID \
  --region us-west-2 \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

echo "Secondary Public IP: $SECONDARY_PUBLIC_IP"
echo "Secondary Private IP: $SECONDARY_PRIVATE_IP"
```

---

## Testing Connectivity

### Test 1: Verify VPC Peering Status

```bash
aws ec2 describe-vpc-peering-connections \
  --vpc-peering-connection-ids $PCX_ID \
  --region us-east-1 \
  --query 'VpcPeeringConnections[0].[VpcPeeringConnectionId,Status.Code]' \
  --output table
```

Expected output: Status should be **active**

---

### Test 2: SSH into Primary Instance

**Wait 2-3 minutes for instance to fully boot**

```bash
ssh -i vpc-peering-demo-east.pem ubuntu@$PRIMARY_PUBLIC_IP
```

If prompted to accept the key, type `yes`

---

### Test 3: Ping Secondary Instance from Primary (via Private IP)

From the Primary instance SSH session:

```bash
ping -c 4 $SECONDARY_PRIVATE_IP
```

**Expected Result:** All 4 packets should be received successfully

Example output:
```
PING 10.1.1.x (10.1.1.x) 56(84) bytes of data.
64 bytes from 10.1.1.x: icmp_seq=1 ttl=62 time=XX.X ms
64 bytes from 10.1.1.x: icmp_seq=2 ttl=62 time=XX.X ms
64 bytes from 10.1.1.x: icmp_seq=3 ttl=62 time=XX.X ms
64 bytes from 10.1.1.x: icmp_seq=4 ttl=62 time=XX.X ms
```

---

### Test 4: SSH from Primary to Secondary

From the Primary instance SSH session:

```bash
ssh -o StrictHostKeyChecking=no ubuntu@$SECONDARY_PRIVATE_IP
```

**Expected Result:** Should connect successfully via the peering connection

---

### Test 5: Verify Apache Web Server

From the Secondary instance (if connected via Test 4):

```bash
# Check if Apache is running
systemctl status apache2

# View the web page
curl localhost
```

---

### Test 6: Exit and Test Reverse Direction

Exit the SSH sessions:
```bash
exit  # from secondary back to primary
exit  # from primary back to local machine
```

SSH into Secondary Instance:
```bash
ssh -i vpc-peering-demo-west.pem ubuntu@$SECONDARY_PUBLIC_IP
```

Ping Primary from Secondary:
```bash
ping -c 4 $PRIMARY_PRIVATE_IP
```

---

## Troubleshooting

### Issue 1: Cannot SSH into Instance

**Problem:** `ssh: connect to host X.X.X.X port 22: Connection timed out`

**Solutions:**
- Verify Security Group allows SSH (port 22) from your IP
- Ensure instance has a public IP assigned
- Check that Internet Gateway is attached to the VPC
- Wait another minute for instance initialization

**Test Security Group:**
```bash
aws ec2 describe-security-groups \
  --group-ids $PRIMARY_SG_ID \
  --region us-east-1 \
  --query 'SecurityGroups[0].IpPermissions'
```

---

### Issue 2: Ping Fails Between Instances

**Problem:** `Destination Host Unreachable` or no response

**Solutions:**
1. **Verify VPC Peering Status is "active":**
```bash
aws ec2 describe-vpc-peering-connections \
  --vpc-peering-connection-ids $PCX_ID \
  --region us-east-1
```

2. **Verify Routes are configured:**
```bash
# Check Primary route table
aws ec2 describe-route-tables \
  --route-table-ids $PRIMARY_RT_ID \
  --region us-east-1

# Check Secondary route table
aws ec2 describe-route-tables \
  --route-table-ids $SECONDARY_RT_ID \
  --region us-west-2
```

Should have routes for both `0.0.0.0/0` and the peer VPC CIDR.

3. **Verify Security Group Rules:**
```bash
# Check Primary SG
aws ec2 describe-security-groups \
  --group-ids $PRIMARY_SG_ID \
  --region us-east-1

# Check Secondary SG
aws ec2 describe-security-groups \
  --group-ids $SECONDARY_SG_ID \
  --region us-west-2
```

Should have ICMP rule allowing from peer VPC CIDR.

---

### Issue 3: VPC Peering Connection Stuck in "Pending Acceptance"

**Problem:** Status shows `pending-acceptance`

**Solution:**
```bash
# Make sure you accepted the connection
aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $PCX_ID \
  --region us-west-2
```

---

### Issue 4: No Internet Connectivity from Instance

**Problem:** Instance cannot reach external websites

**Solutions:**
1. Verify Internet Gateway is attached:
```bash
aws ec2 describe-internet-gateways \
  --internet-gateway-ids $PRIMARY_IGW_ID \
  --region us-east-1
```

2. Verify default route exists in route table:
```bash
aws ec2 describe-route-tables \
  --route-table-ids $PRIMARY_RT_ID \
  --region us-east-1 \
  --query 'RouteTables[0].Routes'
```

---

## Cleanup

To delete all resources and avoid AWS charges:

### Delete EC2 Instances
```bash
aws ec2 terminate-instances \
  --instance-ids $PRIMARY_INSTANCE_ID \
  --region us-east-1

aws ec2 terminate-instances \
  --instance-ids $SECONDARY_INSTANCE_ID \
  --region us-west-2

# Wait for instances to terminate (2-3 minutes)
```

### Delete VPC Peering Connection
```bash
aws ec2 delete-vpc-peering-connection \
  --vpc-peering-connection-id $PCX_ID \
  --region us-east-1
```

### Delete Route Tables
```bash
# Get default route table IDs if needed, then delete custom ones
aws ec2 delete-route-table \
  --route-table-id $PRIMARY_RT_ID \
  --region us-east-1

aws ec2 delete-route-table \
  --route-table-id $SECONDARY_RT_ID \
  --region us-west-2
```

### Detach and Delete Internet Gateways
```bash
aws ec2 detach-internet-gateway \
  --internet-gateway-id $PRIMARY_IGW_ID \
  --vpc-id $PRIMARY_VPC_ID \
  --region us-east-1

aws ec2 delete-internet-gateway \
  --internet-gateway-id $PRIMARY_IGW_ID \
  --region us-east-1

aws ec2 detach-internet-gateway \
  --internet-gateway-id $SECONDARY_IGW_ID \
  --vpc-id $SECONDARY_VPC_ID \
  --region us-west-2

aws ec2 delete-internet-gateway \
  --internet-gateway-id $SECONDARY_IGW_ID \
  --region us-west-2
```

### Delete Subnets
```bash
aws ec2 delete-subnet \
  --subnet-id $PRIMARY_SUBNET_ID \
  --region us-east-1

aws ec2 delete-subnet \
  --subnet-id $SECONDARY_SUBNET_ID \
  --region us-west-2
```

### Delete Security Groups
```bash
aws ec2 delete-security-group \
  --group-id $PRIMARY_SG_ID \
  --region us-east-1

aws ec2 delete-security-group \
  --group-id $SECONDARY_SG_ID \
  --region us-west-2
```

### Delete VPCs
```bash
aws ec2 delete-vpc \
  --vpc-id $PRIMARY_VPC_ID \
  --region us-east-1

aws ec2 delete-vpc \
  --vpc-id $SECONDARY_VPC_ID \
  --region us-west-2
```

### Delete Key Pairs (Optional)
```bash
aws ec2 delete-key-pair \
  --key-name vpc-peering-demo-east \
  --region us-east-1

aws ec2 delete-key-pair \
  --key-name vpc-peering-demo-west \
  --region us-west-2

# Also delete local .pem files
rm vpc-peering-demo-east.pem vpc-peering-demo-west.pem
```

---

## Summary Checklist

- ✅ Created 2 VPCs in different regions (us-east-1, us-west-2)
- ✅ Created subnets in both VPCs
- ✅ Created and attached Internet Gateways
- ✅ Configured Route Tables with internet routes
- ✅ Created VPC Peering Connection
- ✅ Added peering routes to both Route Tables
- ✅ Created Security Groups with appropriate rules
- ✅ Launched EC2 instances with Apache web server
- ✅ Tested connectivity between instances via private IPs
- ✅ Verified cross-region VPC peering works
- ✅ Cleaned up all resources

---

## Key Learnings

### Why VPC Peering?
- **Cost:** Uses AWS internal network (no data transfer charges)
- **Performance:** Lower latency compared to internet routing
- **Security:** Traffic stays within AWS network
- **Simplicity:** Private IP communication between VPCs

### Cross-Region Considerations
- Peering works across regions seamlessly
- Latency is higher than same-region but still acceptable
- DNS resolution may require manual configuration
- Perfect for disaster recovery and multi-region architectures

### Best Practices
1. Use specific CIDR blocks for peering (not allowing all traffic)
2. Implement least-privilege security group rules
3. Monitor peering connection status
4. Document peering topology for compliance
5. Test connectivity before considering setup complete

---

## References

- [AWS VPC Peering Documentation](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html)
- [AWS CLI EC2 Commands](https://docs.aws.amazon.com/cli/latest/reference/ec2/)
- [VPC Peering Best Practices](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html)

---

**Document Created:** January 29, 2026  
**Course:** 30 Days of AWS with Terraform  
**Day:** 15 - VPC Peering Mini Project
