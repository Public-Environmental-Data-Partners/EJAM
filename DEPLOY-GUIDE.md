# EJAM Deployment Guide

> **Hosting infrastructure for the EJAM R Shiny application on AWS ECS Fargate.**
> This guide covers first-time environment setup, Terraform provisioning, Docker image builds, and the GitHub Actions deployment workflow.

---

## Related Files

| File | Purpose |
|---|---|
| `ejam-infra/main.tf` | Terraform — full AWS infrastructure definition |
| `Dockerfile` | Container image build instructions |
| `.dockerignore` | Files excluded from the Docker build context |
| `.github/workflows/deploy.yaml` | GitHub Actions CI/CD deployment workflow |

---

## Branching Strategy

```
main  ──►  dev-deploy  ──►  prod-deploy
```

| Branch | Environment | Infrastructure |
|---|---|---|
| `prod-deploy` | Production | `ejam-prod-*` resources |
| `dev-deploy` | Development | `ejam-dev-*` resources *(in progress)* |

**Workflow:**
1. Develop on feature branches, merge to `main` via PR
2. Merge `main` → `dev-deploy` to validate on dev infrastructure
3. After validation, merge `dev-deploy` → `prod-deploy` to release to prod

> **Coming soon:** Automated branch-based deploys via GitHub Actions — pushes to `dev-deploy` trigger a dev environment deploy, pushes to `prod-deploy` trigger a prod deploy. Each environment points to its own isolated AWS infrastructure. Shared resources (ECR repository) will be evaluated to reduce cost.

---

## Prerequisites

Install the following tools before proceeding.

### Homebrew (Mac)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Terraform
```bash
brew install hashicorp/tap/terraform
```

### AWS CLI
```bash
brew install awscli
```

### Docker Desktop
Download and install from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/). Ensure it is running before any Docker steps.

---

## 1. Repository Setup

```bash
git clone <repo-url>
cd EJAM-mc
git checkout prod-deploy   # or dev-deploy for the dev environment
```

---

## 2. AWS Configuration

### Configure credentials
Contact Vim Shah if you need AWS credentials issued.

```bash
aws configure
```

You will be prompted for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `us-east-1`
- Default output format: `json`

### Verify credentials
```bash
aws sts get-caller-identity
```

Expected output:
```json
{
  "UserId": "...",
  "Account": "716228812058",
  "Arn": "arn:aws:iam::716228812058:user/your.name"
}
```

### Attach IAM policy
Your AWS user requires a custom policy (`ejam-terraform-deploy`) to provision infrastructure. Contact Gabriel Watson for the policy JSON. Attach it via:

**AWS Console → IAM → Users → `<your-user>` → Add permissions → Attach policies**

---

## 3. Terraform — Provision Infrastructure

Run these commands from the `ejam-infra/` directory.

```bash
cd ejam-infra
```

### Initialize
```bash
terraform init
```

### Plan
Review what will be created before applying.

```bash
terraform plan -var="aws_account_id=$(aws sts get-caller-identity --query Account --output text)"
```

### Apply
```bash
terraform apply -var="aws_account_id=$(aws sts get-caller-identity --query Account --output text)"
```

Type `yes` when prompted.

### Record outputs
After a successful apply, Terraform prints the infrastructure endpoints. Save these — you will need the ECR URL for Docker steps.

```
alb_dns_name       = "http://ejam-prod-alb-<id>.us-east-1.elb.amazonaws.com"
ecr_repository_url = "716228812058.dkr.ecr.us-east-1.amazonaws.com/ejam"
ecs_cluster_name   = "ejam-prod-cluster"
ecs_service_name   = "ejam-prod-service"
```

---

## 4. Docker — Build & Push Image

> **Recommendation:** Push the image via GitHub Actions (see Section 5) rather than locally. The uncompressed image is ~4 GB and local pushes are slow on typical connections.

If you need to push manually:

### Authenticate Docker to ECR
```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    716228812058.dkr.ecr.us-east-1.amazonaws.com
```

### Build the image
Ensure Docker Desktop is running first.
```bash
docker build -t ejam .
```

Validate the build succeeded in Docker Desktop before pushing.

### Tag and push
```bash
docker tag ejam:latest 716228812058.dkr.ecr.us-east-1.amazonaws.com/ejam:latest
docker push 716228812058.dkr.ecr.us-east-1.amazonaws.com/ejam:latest
```

### `.dockerignore`
The following are excluded from the build context (`.dockerignore` in repo root):
```
.RData
.Rhistory
.Rproj.user
.git
.github
ejam-infra
```

---

## 5. GitHub Actions — Automated Deploy

The preferred deployment path. On push to the appropriate branch, the `deploy.yaml` workflow builds the Docker image, pushes it to ECR, and updates the ECS service.

### Required secrets
Configure these in **GitHub → Settings → Secrets and variables → Actions**:

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |

### Trigger a deploy
The workflow can be triggered manually from **GitHub → Actions → deploy.yaml → Run workflow**, selecting the target branch.

---

## 6. Teardown

```bash
cd ejam-infra
terraform destroy -var="aws_account_id=$(aws sts get-caller-identity --query Account --output text)"
```

> **Note:** The prod ALB has deletion protection enabled. You must disable it in the AWS Console before `terraform destroy` will succeed on prod: **EC2 → Load Balancers → `ejam-prod-alb` → Actions → Edit attributes → Deletion protection: off**.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `UnauthorizedOperation` on any EC2/ECS/IAM action | Add the missing action to the `ejam-terraform-deploy` IAM policy |
| Docker build fails | Verify Docker Desktop is running; check `.dockerignore` is present |
| ECS tasks failing health checks | Confirm the container exposes port 2001 and returns HTTP 200 on `GET /` |
| Slow local Docker push | Use GitHub Actions instead (Section 5) |

---

## Infrastructure Overview

```
Internet
   │
   ▼
ALB (ejam-prod-alb)  ← port 80
   │
   ▼
ECS Service (2 tasks, 2 vCPU / 7 GB each)
   │
   ├── Task 1  [us-east-1a]
   └── Task 2  [us-east-1b]
         │
         └── Container: ejam  (port 2000 app / 2001 health)
                   │
                   └── Image pulled from ECR (ejam repo)
```

**Resources created by Terraform:**
- VPC + 2 public subnets (us-east-1a/b) + IGW
- Application Load Balancer + target group + HTTP listener
- ECS Fargate cluster + service + task definition
- ECR repository (`ejam`) with image scanning + lifecycle policy
- IAM execution role + task role
- CloudWatch log group (`/ecs/ejam-prod`, 30-day retention)
