## Step 4: Document Architecture (docs/architecture.md)

### 4.1 Create Architecture Documentation
```markdown
# Architecture Documentation

## Infrastructure Components

### Networking
- VPC with public and private subnets
- Internet Gateway
- Route tables

### Compute
- EC2 instances in multiple AZs
- Auto Scaling Group (optional)

### Load Balancing
- Application Load Balancer (ALB)
- Target Groups
- Health checks

### Security
- Security Groups
- IAM roles and policies

## Data Flow
1. User requests → ALB
2. ALB → Target Group
3. Target Group → EC2 instances
4. EC2 serves static content

## Diagram
[Include architecture diagram using tools like draw.io or Lucidchart]
