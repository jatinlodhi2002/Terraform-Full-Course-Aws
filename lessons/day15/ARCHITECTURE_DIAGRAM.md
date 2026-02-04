# VPC Peering Architecture - Complete Workflow & Diagrams

## Table of Contents
1. [High-Level Architecture Overview](#high-level-architecture-overview)
2. [Detailed Component Diagram](#detailed-component-diagram)
3. [Network Flow Diagrams](#network-flow-diagrams)
4. [Traffic Flow Scenarios](#traffic-flow-scenarios)
5. [Security Architecture](#security-architecture)
6. [Routing Architecture](#routing-architecture)
7. [Complete Workflow Explanation](#complete-workflow-explanation)
8. [Advanced Architecture Extensions](#advanced-architecture-extensions)

---

## High-Level Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud Infrastructure                          │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────┐   VPC Peering   ┌─────────────────────────────────┐
│  │   Region: us-east-1             │ ◄─────────────► │   Region: us-west-2             │
│  │   (N. Virginia)                 │                 │   (Oregon)                      │
│  │                                 │                 │                                 │
│  │  ┌───────────────────────────┐  │                 │  ┌───────────────────────────┐  │
│  │  │  Primary VPC              │  │                 │  │  Secondary VPC            │  │
│  │  │  CIDR: 10.0.0.0/16        │  │                 │  │  CIDR: 10.1.0.0/16        │  │
│  │  │                           │  │                 │  │                           │  │
│  │  │  ┌─────────────────────┐  │  │                 │  │  ┌─────────────────────┐  │  │
│  │  │  │  Public Subnet      │  │  │                 │  │  │  Public Subnet      │  │  │
│  │  │  │  10.0.1.0/24        │  │  │                 │  │  │  10.1.1.0/24        │  │  │
│  │  │  │                     │  │  │                 │  │  │                     │  │  │
│  │  │  │  ┌───────────────┐  │  │  │                 │  │  │  ┌───────────────┐  │  │  │
│  │  │  │  │ EC2 Instance  │  │  │  │                 │  │  │  │ EC2 Instance  │  │  │  │
│  │  │  │  │ Ubuntu 24.04  │  │  │  │                 │  │  │  │ Ubuntu 24.04  │  │  │  │
│  │  │  │  │ Apache Web    │  │  │  │                 │  │  │  │ Apache Web    │  │  │  │
│  │  │  │  │ 10.0.1.x      │  │  │  │                 │  │  │  │ 10.1.1.x      │  │  │  │
│  │  │  │  │ Public IP     │  │  │  │                 │  │  │  │ Public IP     │  │  │  │
│  │  │  │  └───────────────┘  │  │  │                 │  │  │  └───────────────┘  │  │  │
│  │  │  └─────────────────────┘  │  │                 │  │  └─────────────────────┘  │  │
│  │  │           │                │  │                 │  │           │                │  │
│  │  │           ▼                │  │                 │  │           ▼                │  │
│  │  │  ┌─────────────────────┐  │  │                 │  │  ┌─────────────────────┐  │  │
│  │  │  │   Route Table       │  │  │                 │  │  │   Route Table       │  │  │
│  │  │  │   - 0.0.0.0/0→IGW   │  │  │                 │  │  │   - 0.0.0.0/0→IGW   │  │  │
│  │  │  │   - 10.1.0.0/16→PCX │  │  │                 │  │  │   - 10.0.0.0/16→PCX │  │  │
│  │  │  └─────────────────────┘  │  │                 │  │  └─────────────────────┘  │  │
│  │  │                           │  │                 │  │                           │  │
│  │  │  ┌─────────────────────┐  │  │                 │  │  ┌─────────────────────┐  │  │
│  │  │  │ Internet Gateway    │  │  │                 │  │  │ Internet Gateway    │  │  │
│  │  │  │ (Primary-IGW)       │  │  │                 │  │  │ (Secondary-IGW)     │  │  │
│  │  │  └──────────┬──────────┘  │  │                 │  │  └──────────┬──────────┘  │  │
│  │  └─────────────┼─────────────┘  │                 │  └─────────────┼─────────────┘  │
│  └────────────────┼────────────────┘                 └────────────────┼────────────────┘
│                   │                                                   │                 │
└───────────────────┼───────────────────────────────────────────────────┼─────────────────┘
                    │                                                   │
                    ▼                                                   ▼
            ┌───────────────┐                                   ┌───────────────┐
            │   Internet    │                                   │   Internet    │
            └───────────────┘                                   └───────────────┘

Legend:
  VPC      = Virtual Private Cloud
  IGW      = Internet Gateway
  PCX      = VPC Peering Connection
  ◄─────► = Peering Connection
  ─────    = Network Connection
  ▼        = Traffic Flow Direction
```

---

## Detailed Component Diagram

### Component Breakdown

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           PRIMARY VPC COMPONENTS (us-east-1)                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  VPC Configuration:                                                                  │
│  ├─ VPC ID: vpc-xxxxxxxxx                                                           │
│  ├─ CIDR Block: 10.0.0.0/16                                                         │
│  ├─ DNS Hostnames: Enabled                                                          │
│  └─ DNS Resolution: Enabled                                                         │
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  Public Subnet (subnet-aaaaaa)                                              │   │
│  │  ├─ CIDR: 10.0.1.0/24                                                       │   │
│  │  ├─ Availability Zone: us-east-1a                                           │   │
│  │  ├─ Auto-assign Public IP: Enabled                                          │   │
│  │  └─ Available IPs: 251 (10.0.1.0 - 10.0.1.255)                              │   │
│  │                                                                              │   │
│  │  ┌────────────────────────────────────────────────────────────────────┐     │   │
│  │  │  EC2 Instance (i-jjjjjj) - Primary-VPC-Instance                   │     │   │
│  │  │  ├─ AMI: Ubuntu 24.04 LTS (ami-xxxxxxxxx)                          │     │   │
│  │  │  ├─ Instance Type: t2.micro                                        │     │   │
│  │  │  ├─ Private IP: 10.0.1.x                                           │     │   │
│  │  │  ├─ Public IP: x.x.x.x                                             │     │   │
│  │  │  ├─ Key Pair: vpc-peering-demo-east                                │     │   │
│  │  │  └─ Security Group: sg-hhhhhh (Primary-VPC-SG)                     │     │   │
│  │  │     ├─ Inbound Rules:                                              │     │   │
│  │  │     │  ├─ SSH (22) from 0.0.0.0/0                                  │     │   │
│  │  │     │  ├─ ICMP from 10.1.0.0/16                                    │     │   │
│  │  │     │  └─ HTTP (80) from 10.1.0.0/16                               │     │   │
│  │  │     └─ Outbound Rules:                                             │     │   │
│  │  │        └─ All traffic to 0.0.0.0/0                                 │     │   │
│  │  │                                                                     │     │   │
│  │  │  Software Installed:                                               │     │   │
│  │  │  └─ Apache Web Server (httpd) - listening on port 80               │     │   │
│  │  └────────────────────────────────────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  Internet Gateway (igw-cccccc) - Primary-IGW                                │   │
│  │  ├─ State: attached                                                          │   │
│  │  └─ Attachment: Primary-VPC                                                  │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  Route Table (rtb-eeeeee) - Primary-Route-Table                             │   │
│  │  ├─ Associated Subnet: Primary-Subnet                                       │   │
│  │  └─ Routes:                                                                  │   │
│  │     ├─ 10.0.0.0/16 → local (default VPC route)                              │   │
│  │     ├─ 10.1.0.0/16 → pcx-gggggg (to Secondary VPC)                          │   │
│  │     └─ 0.0.0.0/0 → igw-cccccc (to Internet)                                 │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        SECONDARY VPC COMPONENTS (us-west-2)                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  VPC Configuration:                                                                  │
│  ├─ VPC ID: vpc-yyyyyyyyy                                                           │
│  ├─ CIDR Block: 10.1.0.0/16                                                         │
│  ├─ DNS Hostnames: Enabled                                                          │
│  └─ DNS Resolution: Enabled                                                         │
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  Public Subnet (subnet-bbbbbb)                                              │   │
│  │  ├─ CIDR: 10.1.1.0/24                                                       │   │
│  │  ├─ Availability Zone: us-west-2a                                           │   │
│  │  ├─ Auto-assign Public IP: Enabled                                          │   │
│  │  └─ Available IPs: 251 (10.1.1.0 - 10.1.1.255)                              │   │
│  │                                                                              │   │
│  │  ┌────────────────────────────────────────────────────────────────────┐     │   │
│  │  │  EC2 Instance (i-kkkkkk) - Secondary-VPC-Instance                 │     │   │
│  │  │  ├─ AMI: Ubuntu 24.04 LTS (ami-yyyyyyyyy)                          │     │   │
│  │  │  ├─ Instance Type: t2.micro                                        │     │   │
│  │  │  ├─ Private IP: 10.1.1.x                                           │     │   │
│  │  │  ├─ Public IP: y.y.y.y                                             │     │   │
│  │  │  ├─ Key Pair: vpc-peering-demo-west                                │     │   │
│  │  │  └─ Security Group: sg-iiiiii (Secondary-VPC-SG)                   │     │   │
│  │  │     ├─ Inbound Rules:                                              │     │   │
│  │  │     │  ├─ SSH (22) from 0.0.0.0/0                                  │     │   │
│  │  │     │  ├─ ICMP from 10.0.0.0/16                                    │     │   │
│  │  │     │  └─ HTTP (80) from 10.0.0.0/16                               │     │   │
│  │  │     └─ Outbound Rules:                                             │     │   │
│  │  │        └─ All traffic to 0.0.0.0/0                                 │     │   │
│  │  │                                                                     │     │   │
│  │  │  Software Installed:                                               │     │   │
│  │  │  └─ Apache Web Server (httpd) - listening on port 80               │     │   │
│  │  └────────────────────────────────────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  Internet Gateway (igw-dddddd) - Secondary-IGW                              │   │
│  │  ├─ State: attached                                                          │   │
│  │  └─ Attachment: Secondary-VPC                                                │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  Route Table (rtb-ffffff) - Secondary-Route-Table                           │   │
│  │  ├─ Associated Subnet: Secondary-Subnet                                     │   │
│  │  └─ Routes:                                                                  │   │
│  │     ├─ 10.1.0.0/16 → local (default VPC route)                              │   │
│  │     ├─ 10.0.0.0/16 → pcx-gggggg (to Primary VPC)                            │   │
│  │     └─ 0.0.0.0/0 → igw-dddddd (to Internet)                                 │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        VPC PEERING CONNECTION (Cross-Region)                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  Peering Connection Details:                                                        │
│  ├─ Peering Connection ID: pcx-gggggg                                               │
│  ├─ Name: Primary-to-Secondary-Peering                                              │
│  ├─ Status: Active                                                                   │
│  ├─ Requester VPC: vpc-xxxxxxxxx (Primary VPC, us-east-1)                           │
│  ├─ Accepter VPC: vpc-yyyyyyyyy (Secondary VPC, us-west-2)                          │
│  ├─ Type: Inter-region                                                              │
│  └─ DNS Resolution: Disabled (can be enabled)                                       │
│                                                                                      │
│  Connection Properties:                                                              │
│  ├─ Traffic: Uses AWS backbone network (not public internet)                        │
│  ├─ Encryption: Traffic isolated but not encrypted (use TLS at app layer)           │
│  ├─ Bandwidth: No hard limit (scales automatically)                                 │
│  ├─ Cost: $0.01/GB cross-region data transfer                                       │
│  └─ Latency: ~70-90ms (us-east-1 ↔ us-west-2)                                      │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Network Flow Diagrams

### 1. Internet Access Flow (Outbound)

```
┌──────────────┐
│   User/You   │
└──────┬───────┘
       │ SSH (Port 22)
       │
       ▼
┌──────────────────────────────────────┐
│  Internet                            │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Internet Gateway (Primary-IGW)      │
│  ├─ Performs NAT                     │
│  └─ Maps Public IP ↔ Private IP      │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Route Table (Primary-Route-Table)   │
│  └─ Checks: 0.0.0.0/0 → IGW         │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Security Group (Primary-VPC-SG)     │
│  └─ Checks: Allow SSH from 0.0.0.0/0│
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  EC2 Instance (10.0.1.x)             │
│  └─ SSH daemon listening on port 22  │
└──────────────────────────────────────┘

Return Path (Stateful - Automatic):
Instance → Security Group (allows return) → IGW → Internet → User
```

---

### 2. VPC Peering Traffic Flow (East to West)

```
Instance in Primary VPC pings Instance in Secondary VPC

Step 1: Initiate Connection
┌──────────────────────────────────────┐
│  EC2 Instance (Primary)              │
│  Source: 10.0.1.x                    │
│  Destination: 10.1.1.x               │
│  └─ ping 10.1.1.x                    │
└──────┬───────────────────────────────┘
       │ ICMP Echo Request
       ▼

Step 2: Check Security Group (Egress)
┌──────────────────────────────────────┐
│  Security Group (Primary-VPC-SG)     │
│  └─ Outbound: Allow All → ✅         │
└──────┬───────────────────────────────┘
       │
       ▼

Step 3: Route Table Lookup
┌──────────────────────────────────────┐
│  Route Table (Primary-Route-Table)   │
│  └─ 10.1.0.0/16 → pcx-gggggg → ✅   │
└──────┬───────────────────────────────┘
       │
       ▼

Step 4: VPC Peering Connection
┌──────────────────────────────────────┐
│  VPC Peering Connection              │
│  ├─ Status: Active ✅                │
│  ├─ Uses: AWS Backbone Network       │
│  └─ Latency: ~70-90ms                │
└──────┬───────────────────────────────┘
       │ Crosses AWS Regions
       │ (us-east-1 → us-west-2)
       ▼

Step 5: Route Table Lookup (Secondary)
┌──────────────────────────────────────┐
│  Route Table (Secondary-Route-Table) │
│  └─ 10.0.0.0/16 → pcx-gggggg → ✅   │
└──────┬───────────────────────────────┘
       │
       ▼

Step 6: Check Security Group (Ingress)
┌──────────────────────────────────────┐
│  Security Group (Secondary-VPC-SG)   │
│  └─ Inbound: ICMP from 10.0.0.0/16 ✅│
└──────┬───────────────────────────────┘
       │
       ▼

Step 7: Deliver to Destination
┌──────────────────────────────────────┐
│  EC2 Instance (Secondary)            │
│  └─ Receives ICMP Echo Request       │
│  └─ Sends ICMP Echo Reply            │
└──────┬───────────────────────────────┘
       │
       ▼ (Return path: reverse of above)

Result: Ping successful! 4 packets sent, 4 received
```

---

### 3. HTTP Request Flow (Primary → Secondary)

```
User on Primary Instance requests web page from Secondary Instance

┌────────────────────────────────────────────────────────────────┐
│  Primary Instance (10.0.1.x)                                   │
│  Command: curl http://10.1.1.x                                 │
└────────┬───────────────────────────────────────────────────────┘
         │
         │ Step 1: DNS Resolution (not needed, using IP)
         │ Step 2: Establish TCP connection
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│  TCP 3-Way Handshake                                           │
│  ├─ SYN: 10.0.1.x:xxxxx → 10.1.1.x:80                         │
│  ├─ SYN-ACK: 10.1.1.x:80 → 10.0.1.x:xxxxx                     │
│  └─ ACK: 10.0.1.x:xxxxx → 10.1.1.x:80                         │
└────────┬───────────────────────────────────────────────────────┘
         │ Connection Established
         ▼
┌────────────────────────────────────────────────────────────────┐
│  HTTP GET Request                                              │
│  GET / HTTP/1.1                                                │
│  Host: 10.1.1.x                                                │
│  User-Agent: curl/7.x                                          │
└────────┬───────────────────────────────────────────────────────┘
         │
         │ Traverses: Primary SG → Route Table → Peering →
         │            Secondary Route Table → Secondary SG
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│  Apache Web Server (Secondary Instance)                        │
│  ├─ Receives HTTP GET request                                  │
│  ├─ Processes request                                           │
│  ├─ Reads /var/www/html/index.html                            │
│  └─ Sends HTTP 200 OK response                                 │
└────────┬───────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│  HTTP Response                                                  │
│  HTTP/1.1 200 OK                                               │
│  Content-Type: text/html                                       │
│  Content-Length: xxx                                           │
│                                                                 │
│  <h1>Secondary VPC Instance - us-west-2</h1>                  │
│  <p>Private IP: 10.1.1.x</p>                                  │
└────────┬───────────────────────────────────────────────────────┘
         │
         │ Return path via peering connection
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│  Primary Instance                                              │
│  └─ Displays HTML content                                      │
└────────────────────────────────────────────────────────────────┘

Total Time: ~80-100ms (including cross-region latency)
```

---

## Traffic Flow Scenarios

### Scenario 1: Successful SSH Connection

```
┌─────────────────────────────────────────────────────────────────────────┐
│  SCENARIO: SSH from Internet to Primary Instance                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  [You] ─── SSH (22) ──→ [Internet] ─── Public IP ──→ [IGW]            │
│                                             │                            │
│                                             ▼                            │
│                                    [Route Table Check]                  │
│                                             │                            │
│                                             ▼                            │
│                                    [Security Group]                     │
│                                    Rule: SSH from 0.0.0.0/0 ✅          │
│                                             │                            │
│                                             ▼                            │
│                                    [EC2 Instance: 10.0.1.x]             │
│                                    SSH Daemon: Listening ✅              │
│                                                                          │
│  Result: ✅ Connection Successful                                       │
│  Response: ubuntu@ip-10-0-1-x:~$                                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Scenario 2: Ping Between VPCs (Primary → Secondary)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  SCENARIO: Ping from Primary to Secondary (Cross-Region)               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  [Primary Instance: 10.0.1.x]                                          │
│           │                                                             │
│           │ Command: ping 10.1.1.x                                     │
│           ▼                                                             │
│  [Security Group: Egress Check]                                        │
│  Rule: All traffic allowed ✅                                          │
│           │                                                             │
│           ▼                                                             │
│  [Primary Route Table]                                                 │
│  Lookup: 10.1.1.x                                                      │
│  Match: 10.1.0.0/16 → pcx-gggggg ✅                                    │
│           │                                                             │
│           ▼                                                             │
│  ╔═══════════════════════════════════════╗                             │
│  ║  VPC Peering Connection (pcx-gggggg)  ║                             │
│  ║  ├─ Crosses AWS Backbone Network      ║                             │
│  ║  ├─ us-east-1 → us-west-2            ║                             │
│  ║  └─ Latency: ~70ms                   ║                             │
│  ╚═══════════════════════════════════════╝                             │
│           │                                                             │
│           ▼                                                             │
│  [Secondary Route Table]                                               │
│  Incoming: From 10.0.1.x                                               │
│  Destination: 10.1.1.x (local) ✅                                      │
│           │                                                             │
│           ▼                                                             │
│  [Security Group: Ingress Check]                                       │
│  Rule: ICMP from 10.0.0.0/16 ✅                                        │
│           │                                                             │
│           ▼                                                             │
│  [Secondary Instance: 10.1.1.x]                                        │
│  Receives: ICMP Echo Request                                           │
│  Sends: ICMP Echo Reply (via same path, reversed)                     │
│                                                                          │
│  Result: ✅ 64 bytes from 10.1.1.x: icmp_seq=1 ttl=62 time=75.2 ms    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Scenario 3: Blocked Traffic (Missing Security Group Rule)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  SCENARIO: HTTP Request Fails - Missing SG Rule                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  [Primary Instance: 10.0.1.x]                                          │
│           │                                                             │
│           │ Command: curl http://10.1.1.x                              │
│           ▼                                                             │
│  [Security Group: Egress Check]                                        │
│  Rule: All traffic allowed ✅                                          │
│           │                                                             │
│           ▼                                                             │
│  [Route Table Check] ✅                                                │
│           │                                                             │
│           ▼                                                             │
│  [VPC Peering Connection] ✅                                           │
│           │                                                             │
│           ▼                                                             │
│  [Secondary Security Group: Ingress Check]                             │
│  Rule Check: HTTP (80) from 10.0.0.0/16                               │
│  Status: ❌ RULE NOT FOUND                                             │
│           │                                                             │
│           ▼                                                             │
│  [PACKET DROPPED]                                                      │
│                                                                          │
│  Result: ❌ Connection timeout                                         │
│  Error: curl: (7) Failed to connect to 10.1.1.x port 80: No route     │
│                                                                          │
│  Fix Required: Add HTTP rule to Secondary-VPC-SG                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Security Architecture

### Defense in Depth - Security Layers

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS ARCHITECTURE                          │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Layer 1: Network Isolation (VPC Level)                                 │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │  • VPC provides isolated network space                     │         │
│  │  • CIDR blocks define address space                        │         │
│  │  • No default connectivity between VPCs                    │         │
│  │  • Peering must be explicitly configured                   │         │
│  └────────────────────────────────────────────────────────────┘         │
│                           ▼                                               │
│                                                                           │
│  Layer 2: Route Table Controls (Subnet Level)                           │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │  • Explicit routes define allowed traffic paths            │         │
│  │  • No route = No connectivity                              │         │
│  │  • 10.1.0.0/16 → pcx-gggggg (specific peering route)      │         │
│  │  • Most specific route wins (longest prefix match)         │         │
│  └────────────────────────────────────────────────────────────┘         │
│                           ▼                                               │
│                                                                           │
│  Layer 3: Network ACLs (Subnet Level - Optional)                        │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │  • Stateless firewall (must allow inbound AND outbound)    │         │
│  │  • Rule numbers determine processing order                 │         │
│  │  • Operates at subnet boundary                             │         │
│  │  • Deny rules processed before allow rules                 │         │
│  └────────────────────────────────────────────────────────────┘         │
│                           ▼                                               │
│                                                                           │
│  Layer 4: Security Groups (Instance Level)                              │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │  Primary-VPC-SG (sg-hhhhhh):                               │         │
│  │  ├─ Inbound Rules:                                         │         │
│  │  │  ├─ SSH (22) from 0.0.0.0/0                            │         │
│  │  │  ├─ ICMP from 10.1.0.0/16 (peer VPC only)              │         │
│  │  │  └─ HTTP (80) from 10.1.0.0/16 (peer VPC only)         │         │
│  │  ├─ Outbound Rules:                                        │         │
│  │  │  └─ All traffic to 0.0.0.0/0                           │         │
│  │  └─ Stateful: Return traffic automatically allowed        │         │
│  └────────────────────────────────────────────────────────────┘         │
│                           ▼                                               │
│                                                                           │
│  Layer 5: Instance-Level Firewall (OS Level - Optional)                 │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │  • iptables / ufw on Linux                                 │         │
│  │  • Additional application-level controls                   │         │
│  │  • Process-level restrictions                              │         │
│  └────────────────────────────────────────────────────────────┘         │
│                           ▼                                               │
│                                                                           │
│  Layer 6: Application-Level Security                                    │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │  • TLS/SSL encryption for data in transit                  │         │
│  │  • Authentication & Authorization                          │         │
│  │  • Input validation                                        │         │
│  │  • Rate limiting                                           │         │
│  └────────────────────────────────────────────────────────────┘         │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

---

### Security Group Rules Matrix

```
┌────────────────────────────────────────────────────────────────────────────┐
│                   SECURITY GROUP RULES MATRIX                              │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Primary-VPC-SG (sg-hhhhhh):                                               │
│  ┌──────────────────────────────────────────────────────────────────┐     │
│  │  Direction  │  Type  │  Port  │  Protocol  │  Source/Dest       │     │
│  ├──────────────────────────────────────────────────────────────────┤     │
│  │  Inbound    │  SSH   │  22    │  TCP       │  0.0.0.0/0         │     │
│  │  Inbound    │  ICMP  │  -1    │  ICMP      │  10.1.0.0/16       │     │
│  │  Inbound    │  HTTP  │  80    │  TCP       │  10.1.0.0/16       │     │
│  │  Outbound   │  All   │  All   │  All       │  0.0.0.0/0         │     │
│  └──────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  Secondary-VPC-SG (sg-iiiiii):                                             │
│  ┌──────────────────────────────────────────────────────────────────┐     │
│  │  Direction  │  Type  │  Port  │  Protocol  │  Source/Dest       │     │
│  ├──────────────────────────────────────────────────────────────────┤     │
│  │  Inbound    │  SSH   │  22    │  TCP       │  0.0.0.0/0         │     │
│  │  Inbound    │  ICMP  │  -1    │  ICMP      │  10.0.0.0/16       │     │
│  │  Inbound    │  HTTP  │  80    │  TCP       │  10.0.0.0/16       │     │
│  │  Outbound   │  All   │  All   │  All       │  0.0.0.0/0         │     │
│  └──────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  Traffic Analysis:                                                          │
│  ├─ Internet → Primary Instance (SSH): ✅ Allowed (0.0.0.0/0)            │
│  ├─ Internet → Primary Instance (HTTP): ❌ Blocked (no rule)             │
│  ├─ Primary Instance → Secondary Instance (ICMP): ✅ Allowed             │
│  ├─ Primary Instance → Secondary Instance (HTTP): ✅ Allowed             │
│  ├─ Secondary Instance → Primary Instance (ICMP): ✅ Allowed             │
│  └─ Internet → Secondary via Peering: ❌ Impossible (no route)           │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## Routing Architecture

### Complete Routing Table Analysis

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      ROUTING ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  PRIMARY ROUTE TABLE (rtb-eeeeee):                                      │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  Destination      │  Target        │  Status  │  Propagated     │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │  10.0.0.0/16      │  local         │  Active  │  No             │  │
│  │  10.1.0.0/16      │  pcx-gggggg    │  Active  │  No             │  │
│  │  0.0.0.0/0        │  igw-cccccc    │  Active  │  No             │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  Route Decision Process:                                                │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  Packet to 10.0.1.5   → Match: 10.0.0.0/16  → local      ✅     │  │
│  │  Packet to 10.1.1.8   → Match: 10.1.0.0/16  → peering    ✅     │  │
│  │  Packet to 8.8.8.8    → Match: 0.0.0.0/0    → IGW        ✅     │  │
│  │  Packet to 192.168.1.1 → Match: 0.0.0.0/0   → IGW        ✅     │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  SECONDARY ROUTE TABLE (rtb-ffffff):                                    │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  Destination      │  Target        │  Status  │  Propagated     │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │  10.1.0.0/16      │  local         │  Active  │  No             │  │
│  │  10.0.0.0/16      │  pcx-gggggg    │  Active  │  No             │  │
│  │  0.0.0.0/0        │  igw-dddddd    │  Active  │  No             │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  Route Decision Process:                                                │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  Packet to 10.1.1.8   → Match: 10.1.0.0/16  → local      ✅     │  │
│  │  Packet to 10.0.1.5   → Match: 10.0.0.0/16  → peering    ✅     │  │
│  │  Packet to 8.8.8.8    → Match: 0.0.0.0/0    → IGW        ✅     │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Longest Prefix Match Example

```
┌─────────────────────────────────────────────────────────────────────────┐
│                LONGEST PREFIX MATCH (LPM) ALGORITHM                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Scenario: Instance needs to send packet to 10.1.1.8                   │
│                                                                          │
│  Available Routes:                                                       │
│  ├─ 0.0.0.0/0        (0 bits match)    → Internet Gateway              │
│  ├─ 10.0.0.0/16      (16 bits match)   → local VPC                     │
│  └─ 10.1.0.0/16      (16 bits match)   → VPC Peering                   │
│                                                                          │
│  Destination IP: 10.1.1.8                                               │
│  Binary: 00001010.00000001.00000001.00001000                           │
│                                                                          │
│  Route Matching:                                                         │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │  Route          │  Binary Prefix         │  Match?  │  Bits   │    │
│  ├────────────────────────────────────────────────────────────────┤    │
│  │  0.0.0.0/0      │  (none)                │  Yes     │  0      │    │
│  │  10.0.0.0/16    │  00001010.00000000     │  No      │  N/A    │    │
│  │  10.1.0.0/16    │  00001010.00000001     │  Yes     │  16     │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  Winner: 10.1.0.0/16 (Most specific = Longest prefix = 16 bits)        │
│  Action: Forward to VPC Peering Connection (pcx-gggggg)                │
│                                                                          │
│  Why not 0.0.0.0/0?                                                     │
│  └─ Although it matches, it's less specific (0 bits vs 16 bits)        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Complete Workflow Explanation

### Workflow 1: Infrastructure Deployment

```
PHASE 1: VPC CREATION
├─ Step 1: Create Primary VPC in us-east-1
│  ├─ Define CIDR: 10.0.0.0/16 (65,536 addresses)
│  ├─ Enable DNS hostnames
│  └─ Enable DNS resolution
│
├─ Step 2: Create Secondary VPC in us-west-2
│  ├─ Define CIDR: 10.1.0.0/16 (non-overlapping!)
│  ├─ Enable DNS hostnames
│  └─ Enable DNS resolution
│
└─ Result: Two isolated virtual networks in different regions

PHASE 2: SUBNET CREATION
├─ Step 3: Create Primary Subnet
│  ├─ CIDR: 10.0.1.0/24 (256 addresses, 251 usable)
│  ├─ Availability Zone: us-east-1a
│  └─ Enable auto-assign public IP
│
├─ Step 4: Create Secondary Subnet
│  ├─ CIDR: 10.1.1.0/24
│  ├─ Availability Zone: us-west-2a
│  └─ Enable auto-assign public IP
│
└─ Result: Public subnets ready for EC2 instances

PHASE 3: INTERNET CONNECTIVITY
├─ Step 5: Create Internet Gateways
│  ├─ Primary IGW → Attach to Primary VPC
│  └─ Secondary IGW → Attach to Secondary VPC
│
├─ Step 6: Configure Route Tables
│  ├─ Primary RT: Add 0.0.0.0/0 → Primary IGW
│  ├─ Secondary RT: Add 0.0.0.0/0 → Secondary IGW
│  └─ Associate subnets with route tables
│
└─ Result: Instances can access the internet

PHASE 4: VPC PEERING
├─ Step 7: Create Peering Connection
│  ├─ Requester: Primary VPC (us-east-1)
│  ├─ Accepter: Secondary VPC (us-west-2)
│  └─ Type: Cross-region
│
├─ Step 8: Accept Peering Request
│  └─ Status changes: pending-acceptance → active
│
├─ Step 9: Update Route Tables
│  ├─ Primary RT: Add 10.1.0.0/16 → pcx-gggggg
│  └─ Secondary RT: Add 10.0.0.0/16 → pcx-gggggg
│
└─ Result: VPCs can communicate privately

PHASE 5: SECURITY CONFIGURATION
├─ Step 10: Create Security Groups
│  ├─ Primary SG: Allow SSH (0.0.0.0/0), ICMP/HTTP (10.1.0.0/16)
│  └─ Secondary SG: Allow SSH (0.0.0.0/0), ICMP/HTTP (10.0.0.0/16)
│
└─ Result: Controlled access to instances

PHASE 6: COMPUTE DEPLOYMENT
├─ Step 11: Launch EC2 Instances
│  ├─ Primary Instance: Ubuntu 24.04, t2.micro, Apache
│  └─ Secondary Instance: Ubuntu 24.04, t2.micro, Apache
│
└─ Result: Working web servers in both VPCs

PHASE 7: TESTING & VALIDATION
├─ Step 12: Test Internet Access
│  └─ SSH from local machine to both instances
│
├─ Step 13: Test VPC Peering
│  ├─ Ping from Primary to Secondary (private IP)
│  ├─ HTTP request from Primary to Secondary
│  └─ Verify reverse connectivity
│
└─ Result: ✅ Complete cross-region VPC peering working!
```

---

### Workflow 2: SSH Connection Sequence

```
DETAILED SSH CONNECTION FLOW

Time: T0 (Start)
┌──────────────────────────────────────────────┐
│ User initiates SSH connection                │
│ Command: ssh -i key.pem ubuntu@54.x.x.x     │
└──────┬───────────────────────────────────────┘
       │
Time: T+5ms (DNS Resolution)
       ├─ DNS lookup for 54.x.x.x (if hostname used)
       │  └─ Not needed (IP address provided)
       │
Time: T+10ms (TCP Handshake Start)
       ├─ Client sends SYN packet
       │  ├─ Source: Your IP:random_port
       │  └─ Destination: 54.x.x.x:22
       │
Time: T+50ms (Packet reaches AWS)
       ├─ Packet enters AWS network
       │  └─ Routed to us-east-1 region
       │
Time: T+55ms (Internet Gateway)
       ├─ IGW performs NAT
       │  ├─ External: 54.x.x.x → Internal: 10.0.1.x
       │  └─ Updates routing table
       │
Time: T+60ms (Route Table Lookup)
       ├─ Primary Route Table consulted
       │  ├─ Destination: 10.0.1.x
       │  └─ Match: 10.0.0.0/16 → local ✅
       │
Time: T+62ms (Security Group Check)
       ├─ Primary-VPC-SG inspected
       │  ├─ Rule: SSH (22) from 0.0.0.0/0
       │  └─ Verdict: ALLOW ✅
       │
Time: T+65ms (Packet Delivered)
       ├─ EC2 instance receives SYN
       │  └─ SSHd daemon listening on port 22
       │
Time: T+66ms (SYN-ACK Sent)
       ├─ Instance responds with SYN-ACK
       │  └─ Return path: automatic (stateful SG)
       │
Time: T+110ms (ACK Received by Client)
       ├─ TCP 3-way handshake complete
       │  └─ Connection established
       │
Time: T+115ms (SSH Protocol Negotiation)
       ├─ SSH version exchange
       ├─ Algorithm negotiation
       └─ Key exchange
       │
Time: T+250ms (Authentication)
       ├─ Public key authentication
       │  ├─ Client sends public key
       │  ├─ Server verifies against authorized_keys
       │  └─ Challenge-response completed
       │
Time: T+300ms (Session Established)
       ├─ SSH session ready
       └─ User sees prompt: ubuntu@ip-10-0-1-x:~$
       │
Total Time: ~300ms (0.3 seconds)
```

---

### Workflow 3: Cross-Region Ping Flow

```
CROSS-REGION ICMP PING DETAILED FLOW

User on Primary Instance pings Secondary Instance

═══════════════════════════════════════════════════════════════
OUTBOUND PATH (Primary → Secondary)
═══════════════════════════════════════════════════════════════

[T+0ms] Command Execution
├─ User types: ping 10.1.1.8
├─ OS creates ICMP Echo Request packet
└─ Packet details:
   ├─ Type: 8 (Echo Request)
   ├─ Source IP: 10.0.1.5
   ├─ Dest IP: 10.1.1.8
   ├─ Sequence: 1
   └─ Size: 64 bytes

[T+1ms] Security Group (Egress)
├─ Primary-VPC-SG checked
├─ Rule: Outbound all traffic allowed
└─ Decision: ALLOW ✅

[T+2ms] Route Table Lookup
├─ Primary Route Table queried
├─ Destination: 10.1.1.8
├─ Match found: 10.1.0.0/16 → pcx-gggggg
└─ Action: Forward to VPC Peering Connection

[T+3ms] Leave Primary VPC
├─ Packet exits Primary VPC
└─ Enters AWS backbone network

[T+3ms-73ms] Cross-Region Transit
├─ Packet traverses AWS private fiber network
├─ Path: us-east-1 data center → us-west-2 data center
├─ Distance: ~2,500 miles (4,000 km)
├─ Latency: ~70ms (speed of light in fiber)
└─ No public internet involved (secure, fast)

[T+73ms] Enter Secondary VPC
├─ Packet arrives in us-west-2
└─ Enters Secondary VPC via peering connection

[T+74ms] Route Table Lookup
├─ Secondary Route Table queried
├─ Source: 10.0.1.5
├─ Destination: 10.1.1.8
├─ Match found: 10.1.0.0/16 → local
└─ Action: Deliver locally

[T+75ms] Security Group (Ingress)
├─ Secondary-VPC-SG checked
├─ Rule: ICMP from 10.0.0.0/16 allowed
├─ Source 10.0.1.5 is in 10.0.0.0/16 range
└─ Decision: ALLOW ✅

[T+76ms] Packet Delivered
├─ EC2 instance 10.1.1.8 receives packet
└─ OS processes ICMP Echo Request

═══════════════════════════════════════════════════════════════
RETURN PATH (Secondary → Primary)
═══════════════════════════════════════════════════════════════

[T+77ms] ICMP Echo Reply Created
├─ OS generates reply packet
└─ Packet details:
   ├─ Type: 0 (Echo Reply)
   ├─ Source IP: 10.1.1.8
   ├─ Dest IP: 10.0.1.5
   ├─ Sequence: 1
   └─ Size: 64 bytes

[T+78ms] Security Group (Egress)
├─ Secondary-VPC-SG checked (outbound)
├─ Stateful: Return traffic auto-allowed
└─ Decision: ALLOW ✅

[T+79ms] Route Table Lookup
├─ Secondary Route Table queried
├─ Destination: 10.0.1.5
├─ Match: 10.0.0.0/16 → pcx-gggggg
└─ Action: Forward via peering

[T+80ms-150ms] Cross-Region Transit
├─ Return journey: us-west-2 → us-east-1
└─ Latency: ~70ms

[T+150ms] Enter Primary VPC
├─ Packet arrives back in us-east-1
└─ Route Table: 10.0.0.0/16 → local

[T+151ms] Security Group Check
├─ Stateful firewall recognizes return packet
├─ Automatically allowed (part of established flow)
└─ Decision: ALLOW ✅

[T+152ms] Packet Delivered
├─ Primary instance receives Echo Reply
└─ Ping utility displays result

═══════════════════════════════════════════════════════════════
OUTPUT DISPLAYED
═══════════════════════════════════════════════════════════════

64 bytes from 10.1.1.8: icmp_seq=1 ttl=62 time=152 ms

Analysis:
├─ Time: 152ms (round-trip)
│  ├─ Outbound: 76ms
│  └─ Return: 76ms
├─ TTL: 62 (started at 64, decremented by 2 hops)
└─ Status: Success ✅
```

---

## Advanced Architecture Extensions

### Extension Diagram 1: Multi-Tier with Private Subnets

```
┌──────────────────────────────────────────────────────────────────┐
│                 PRIMARY VPC (10.0.0.0/16)                        │
│                                                                   │
│  ┌─────────────────────────┐   ┌────────────────────────────┐   │
│  │  Public Subnet          │   │  Private Subnet            │   │
│  │  10.0.1.0/24            │   │  10.0.2.0/24               │   │
│  │                         │   │                            │   │
│  │  ┌──────────────────┐   │   │  ┌─────────────────────┐  │   │
│  │  │  Web Server      │   │   │  │  Database Server    │  │   │
│  │  │  Public IP: Yes  │───┼───┼──│  Public IP: No      │  │   │
│  │  │  10.0.1.5        │   │   │  │  10.0.2.10          │  │   │
│  │  └──────────────────┘   │   │  └─────────────────────┘  │   │
│  │           │              │   │           │               │   │
│  └───────────┼──────────────┘   └───────────┼───────────────┘   │
│              │                               │                   │
│              ▼                               ▼                   │
│      ┌──────────────┐              ┌─────────────────┐          │
│      │     IGW      │              │  NAT Gateway    │          │
│      └──────┬───────┘              │  (in public)    │          │
│             │                      └────────┬────────┘          │
│             │                               │                   │
│             └───────────┬───────────────────┘                   │
│                         │                                       │
└─────────────────────────┼───────────────────────────────────────┘
                          │
                      Internet

Security Flow:
1. Internet → Web Server: ✅ Allowed (public subnet)
2. Internet → Database: ❌ Blocked (no route)
3. Web Server → Database: ✅ Allowed (same VPC)
4. Database → Internet: ✅ Via NAT Gateway (outbound only)
```

---

### Extension Diagram 2: Transit Gateway Hub

```
┌────────────────────────────────────────────────────────────────────┐
│                      TRANSIT GATEWAY ARCHITECTURE                   │
│                                                                     │
│                    ┌─────────────────────┐                         │
│                    │  Transit Gateway    │                         │
│                    │  (Central Hub)      │                         │
│                    │  tgw-xxxxxxxx       │                         │
│                    └──────────┬──────────┘                         │
│                               │                                     │
│        ┌──────────────────────┼────────────────────┐               │
│        │                      │                    │               │
│        ▼                      ▼                    ▼               │
│  ┌──────────┐          ┌──────────┐        ┌──────────┐           │
│  │ Primary  │          │Secondary │        │ Tertiary │           │
│  │   VPC    │          │   VPC    │        │   VPC    │           │
│  │10.0.0.0  │          │10.1.0.0  │        │10.2.0.0  │           │
│  └──────────┘          └──────────┘        └──────────┘           │
│                                                                     │
│  Advantages over Mesh Peering:                                     │
│  ├─ Scalable to 1000s of VPCs                                     │
│  ├─ Transitive routing (A↔B, B↔C, A↔C all work)                  │
│  ├─ Centralized route management                                  │
│  ├─ Support for VPN and Direct Connect                            │
│  └─ Inter-region peering support                                  │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

---

### Extension Diagram 3: Load Balancer with Multi-AZ

```
┌──────────────────────────────────────────────────────────────────┐
│                 HIGH AVAILABILITY ARCHITECTURE                    │
│                                                                   │
│                        ┌─────────┐                               │
│                        │ Internet│                               │
│                        └────┬────┘                               │
│                             │                                     │
│                             ▼                                     │
│              ┌──────────────────────────────┐                    │
│              │ Application Load Balancer    │                    │
│              │ (Multi-AZ)                   │                    │
│              └──────────┬────────┬──────────┘                    │
│                         │        │                               │
│         ┌───────────────┘        └────────────────┐              │
│         │                                         │              │
│         ▼                                         ▼              │
│  ┌─────────────────┐                    ┌─────────────────┐     │
│  │  AZ: us-east-1a │                    │  AZ: us-east-1b │     │
│  │  Subnet 10.0.1.0│                    │  Subnet 10.0.2.0│     │
│  │                 │                    │                 │     │
│  │  ┌───────────┐  │                    │  ┌───────────┐  │     │
│  │  │Web Server1│  │                    │  │Web Server2│  │     │
│  │  │ 10.0.1.5  │  │                    │  │ 10.0.2.5  │  │     │
│  │  └───────────┘  │                    │  └───────────┘  │     │
│  └─────────────────┘                    └─────────────────┘     │
│                                                                   │
│  Traffic Distribution:                                           │
│  ├─ Round-robin: 50% to each instance                           │
│  ├─ Health checks: Remove unhealthy instances                   │
│  ├─ Session affinity: Sticky sessions (optional)                │
│  └─ Fault tolerance: Survives AZ failure                        │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Summary

This architecture provides:

✅ **Isolation:** Separate VPCs in different regions  
✅ **Connectivity:** Private communication via VPC peering  
✅ **Security:** Multi-layer defense (SG, RT, NACL)  
✅ **Scalability:** Can extend with additional components  
✅ **Resilience:** Cross-region redundancy  
✅ **Performance:** AWS backbone network (low latency)  
✅ **Cost-Effective:** No NAT Gateway needed for inter-VPC traffic

---

**Document Version:** 1.0  
**Created:** January 30, 2026  
**Course:** 30 Days of AWS with Terraform - Day 15  
**Architecture:** Cross-Region VPC Peering with EC2 Instances
