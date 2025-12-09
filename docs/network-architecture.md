# EKS Network Architecture Diagram

## VPC Architecture (Multi-AZ)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  VPC (10.0.0.0/16)                                  │
│                                                                                     │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐          │
│  │   us-east-1a       │  │   us-east-1b       │  │   us-east-1c       │          │
│  ├────────────────────┤  ├────────────────────┤  ├────────────────────┤          │
│  │ PUBLIC SUBNET      │  │ PUBLIC SUBNET      │  │ PUBLIC SUBNET      │          │
│  │ 10.0.101.0/24      │  │ 10.0.102.0/24      │  │ 10.0.103.0/24      │          │
│  │                    │  │                    │  │                    │          │
│  │ ┌────────────────┐ │  │                    │  │                    │          │
│  │ │  NAT Gateway   │ │  │                    │  │                    │          │
│  │ │  (Elastic IP)  │ │  │                    │  │                    │          │
│  │ └────────────────┘ │  │                    │  │                    │          │
│  │                    │  │                    │  │                    │          │
│  │ ┌─────────────────────────────────────────────────────────────┐   │          │
│  │ │         Application Load Balancer (ALB)                     │   │          │
│  │ │    (Spans all 3 public subnets - internet-facing)           │   │          │
│  │ └─────────────────────────────────────────────────────────────┘   │          │
│  │         ↕                │         ↕          │         ↕          │          │
│  └─────────│────────────────┘─────────│──────────┘─────────│──────────┘          │
│            │                          │                    │                     │
│         [IGW]◄──────────────────────[IGW]─────────────────[IGW]                 │
│            │                          │                    │                     │
│  ┌─────────▼────────────┐  ┌─────────▼──────────┐  ┌──────▼───────────┐        │
│  │ PRIVATE SUBNET       │  │ PRIVATE SUBNET     │  │ PRIVATE SUBNET   │        │
│  │ 10.0.1.0/24          │  │ 10.0.2.0/24        │  │ 10.0.3.0/24      │        │
│  │                      │  │                    │  │                  │        │
│  │ ┌──────────────────┐ │  │ ┌────────────────┐ │  │ ┌──────────────┐ │        │
│  │ │ EKS Worker Node  │ │  │ │ EKS Worker Node│ │  │ │              │ │        │
│  │ │  (t3.small)      │ │  │ │  (t3.small)    │ │  │ │   Future     │ │        │
│  │ │                  │ │  │ │                │ │  │ │  Karpenter   │ │        │
│  │ │ Pods:            │ │  │ │ Pods:          │ │  │ │   Nodes      │ │        │
│  │ │ - Karpenter      │ │  │ │ - Argo CD      │ │  │ │  (Spot)      │ │        │
│  │ │ - AWS LB Ctrl    │ │  │ │ - CoreDNS      │ │  │ │              │ │        │
│  │ └──────────────────┘ │  │ └────────────────┘ │  │ └──────────────┘ │        │
│  │         │            │  │         │          │  │         │        │        │
│  │         │            │  │         │          │  │         │        │        │
│  │    [Route: NAT GW]  │  │    [Route: NAT GW] │  │    [Route: NAT GW] │       │
│  └─────────┼────────────┘  └─────────┼──────────┘  └─────────┼──────────┘       │
│            │                         │                       │                  │
│            └─────────────────────────┼───────────────────────┘                  │
│                                      │                                          │
│  ┌────────────────────────────────────────────────────────────────────────┐    │
│  │                       VPC Endpoints                                     │    │
│  │                                                                         │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │    │
│  │  │ S3 Gateway   │  │  ECR API     │  │  ECR DKR     │  │    EC2    │  │    │
│  │  │   (FREE)     │  │ (Interface)  │  │ (Interface)  │  │(Interface)│  │    │
│  │  │              │  │   $7/mo      │  │   $7/mo      │  │  $7/mo    │  │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └───────────┘  │    │
│  │                                                                         │    │
│  │  ┌──────────────┐                                                      │    │
│  │  │     STS      │  All Interface endpoints create ENIs in private      │    │
│  │  │ (Interface)  │  subnets for direct AWS service access              │    │
│  │  │   $7/mo      │                                                      │    │
│  │  └──────────────┘                                                      │    │
│  └────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │
                                       ▼
                              ┌─────────────────┐
                              │   INTERNET      │
                              │                 │
                              │  Users access   │
                              │  ALB endpoint   │
                              └─────────────────┘
```

## Traffic Flows

### 1. **User → Application (Inbound)**
```
Internet → Internet Gateway → ALB (Public Subnet) → Worker Node Pods (Private Subnet)
```

### 2. **Worker Nodes → Internet (Outbound)**
```
Private Subnet → NAT Gateway (Public Subnet) → Internet Gateway → Internet
```

### 3. **Worker Nodes → AWS Services (Optimized)**
```
Private Subnet → VPC Endpoints (ENIs in Private Subnet) → AWS Service
(Bypasses NAT Gateway - saves $$$)
```

### 4. **Karpenter Auto-Scaling**
```
Workload deployed → Pods pending → Karpenter detects → 
Creates Spot Instance in Private Subnet → Pod scheduled
```

## Security Groups

### Cluster Security Group
- Allows pod-to-pod communication
- Allows worker node communication
- Tagged for Karpenter discovery

### VPC Endpoint Security Group
- Allows HTTPS (443) from VPC CIDR (10.0.0.0/16)
- Applied to all Interface endpoints

### ALB Security Group
- Allows HTTP (80) from internet (0.0.0.0/0)
- Allows traffic to worker nodes on pod ports

## Cost Breakdown

| Component | Monthly Cost |
|-----------|--------------|
| Internet Gateway | **FREE** |
| NAT Gateway (1) | ~$32 + data transfer |
| S3 VPC Endpoint (Gateway) | **FREE** |
| Interface Endpoints (4 × $7) | ~$28 |
| EKS Worker Nodes (2 × t3.small) | ~$30 |
| **Total Networking** | **~$90/month** |

## Key Design Decisions

✅ **Multi-AZ for high availability** (3 availability zones)
✅ **Private subnets for security** (worker nodes not exposed)
✅ **Single NAT Gateway** (cost vs availability tradeoff)
✅ **VPC Endpoints** (reduce NAT Gateway data charges)
✅ **Gateway type for S3** (free + high throughput)
✅ **Interface type for ECR/EC2/STS** (direct private connectivity)

## Alternative Approaches (Not Used)

❌ **3 NAT Gateways** (1 per AZ) - More HA but $96/mo vs $32/mo
❌ **No VPC Endpoints** - Simpler but higher NAT data charges
❌ **Public worker nodes** - Cheaper but major security risk
❌ **All Interface endpoints** - Can add CloudWatch, ELB, etc. as needed
