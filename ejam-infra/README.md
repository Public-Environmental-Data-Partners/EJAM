# EJAM Infrastructure & Deployment

> AWS ECS Fargate hosting for the EJAM R Shiny app.
> Two environments — **prod** and **dev** — each deployed via GitHub Actions on push to their respective protected branches.

---

## Stack Overview

| Layer | Technology |
|---|---|
| App | R Shiny (rocker/rstudio base image) |
| PDF generation | Google Chrome stable + chromote/pagedown |
| Containerization | Docker (multi-layer build) |
| Container registry | AWS ECR (shared repo `ejam`, owned by prod) |
| Hosting | AWS ECS Fargate |
| Load balancing | AWS ALB (Application Load Balancer) |
| HTTPS / TLS | AWS ACM (DNS-validated via Squarespace) |
| Infrastructure-as-code | Terraform (S3 backend, per-env state) |
| CI/CD | GitHub Actions |
| DNS | Squarespace (CNAME → ALB) |

---

## Stack Wireframe

```
                        ┌─────────────────────────────────────────────────────────────────┐
  LOCAL DEV             │  GITHUB                                                         │
                        │                                                                 │
  ejam-infra/           │   branches:                                                     │
  ├── main.tf           │   ┌──────────┐   PR    ┌────────────┐  push  ┌────────────────┐ │
  ├── prod.tfvars  ─────┼──►│   main   │ ──────► │ dev-deploy │ ─────► │ deploy-dev.yaml│ │
  ├── dev.tfvars        │   │ (default)│ ──────► │prod-deploy │ ─────► │ deploy.yaml    │ │
  └── terraform CLI     │   └──────────┘   PR    └────────────┘  push  └───────┬────────┘ │
                        │                                                      │          │
  Terraform state       │   secrets (Settings → Actions):                      │          │
  S3 bucket:            │   • AWS_ACCESS_KEY_ID                                │          │
  ejam-terraform-state  │   • AWS_SECRET_ACCESS_KEY                            │          │
  -716228812058         │   • GITHUB_TOKEN (auto)                              │          │
  ├── prod/terraform    │   • PIGGYBACK_TOKEN (→ ejamdata releases)            │          │
  │   .tfstate          │                                                      │          │
  └── dev/terraform     └──────────────────────────────────────────────────────┼──────────┘
      .tfstate                                                                   │
                                                                                 │ build + push image
                                                                                 ▼
┌────────────────────────────────────────────────────────────────────────────────────────────┐
│  AWS  (us-east-1, account [acount_id]  )                                                   │
│                                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  ECR  (ejam)                                                                        │   │
│  │  [acount_id].dkr.ecr.us-east-1.amazonaws.com/ejam                                   │   │
│  │  tags: prod-<sha>  /  dev-<sha>                                                     │   │
│  └───────────────────────────────────┬─────────────────────────────────────────────────┘   │
│                                      │ pull image                                          │
│            ┌─────────────────────────┼──────────────────────────┐                          │
│            │                         │                          │                          │
│            ▼  PROD                   │              DEV          ▼                         │
│  ┌─────────────────────┐             │  ┌─────────────────────────────┐                    │
│  │  VPC  10.0.0.0/16   │             │  │  VPC  10.0.0.0/16           │                    │
│  │  ├ subnet us-east-1a│             │  │  ├ subnet us-east-1a        │                    │
│  │  └ subnet us-east-1b│             │  │  └ subnet us-east-1b        │                    │
│  │                     │             │  │                             │                    │
│  │  ALB  ejam-prod-alb │             │  │  ALB  ejam-dev-alb          │                    │
│  │  :80  → redirect    │             │  │  :80  → forward             │                    │
│  │  :443 → TG          │             │  │                             │                    │
│  │                     │             │  │  ECS Cluster ejam-dev       │                    │
│  │  ACM cert           │             │  │  Service  ejam-dev-service  │                    │
│  │  ejam.public        │             │  │  Task     1×(1vCPU / 6GB)   │                    │
│  │  envirodata.org     │             │  │  Port 3838                  │                    │
│  │                     │             │  └─────────────────────────────┘                    │
│  │  ECS Cluster        │             │                                                     │
│  │  ejam-prod-cluster  │             │  IAM roles (per env)                                │
│  │  Service            │             │  • ejam-{env}-ecs-execution                         │
│  │  ejam-prod-service  │             │  • ejam-{env}-ecs-task                              │
│  │  Task               │             │                                                     │
│  │  2×(2vCPU / 7GB)    │             │  CloudWatch log groups                              │
│  │  Port 3838          │             │  • /ecs/ejam-prod  (30d retention)                  │
│  └─────────────────────┘             │  • /ecs/ejam-dev   (7d retention)                   │
│                                      │                                                     │
└──────────────────────────────────────┼─────────────────────────────────────────────────────┘
                                       │
                        ┌──────────────┴──────────────┐
                        │  DNS  (Squarespace)         │
                        │  ejam.publicenvirodata.org  │
                        │  CNAME → ejam-prod-alb-     │
                        │  833585434.us-east-1.elb.   │
                        │  amazonaws.com              │
                        └─────────────────────────────┘
```

---

## URLs

| Environment | URL |
|---|---|
| Production | https://ejam.publicenvirodata.org |
| Production (direct) | http://ejam-prod-alb-833585434.us-east-1.elb.amazonaws.com |
| Dev | http://ejam-dev-alb-971929002.us-east-1.elb.amazonaws.com |

---

## Deploying Changes

### Branching model

```
feature / fix branch  ──── PR ────►  dev-deploy
                      
                      HUMAN REVIEW / STABILITY CHECK
        │
        │             ──── PR ────►  prod-deploy  
        ▼
      main            
```

Changes go to `dev-deploy` and `prod-deploy` via **separate PRs** from the same source (`main` or a feature branch) — not from `dev-deploy` into `prod-deploy`.

### Step-by-step

**1. Develop your changes**
Work on a feature/fix branch and merge to `main` via PR, or keep on a feature branch ready to deploy.

**2. Deploy to dev**
Open a PR from `main` (or your feature branch) → `dev-deploy`.
Once merged, GitHub Actions builds and deploys to dev automatically (~15 min).

**3. Validate on dev**
Test at the dev URL. A human must green-light before promoting to prod.

**4. Deploy to prod**
Open a separate PR from `main` (or the same feature branch) → `prod-deploy`.
Once merged, GitHub Actions deploys to production automatically.

> **Branch protections:** Both `dev-deploy` and `prod-deploy` require a PR — direct pushes are blocked for all users including admins.

---

## Infrastructure Changes (Terraform)

App code deploys happen via GitHub Actions. AWS infrastructure changes (resize tasks, add HTTPS, etc.) require Terraform run locally from `ejam-infra/`.

State is stored in S3 bucket `ejam-terraform-state-716228812058`.

```bash
cd ejam-infra

# Prod
terraform init -backend-config="key=prod/terraform.tfstate"
terraform apply -var-file=prod.tfvars -var="aws_account_id=716228812058"

# Dev
terraform init -backend-config="key=dev/terraform.tfstate" -reconfigure
terraform apply -var-file=dev.tfvars -var="aws_account_id=716228812058"
```

### Adding a custom domain (HTTPS)
Set `domain_name = "ejam.yourdomain.com"` in the relevant `.tfvars`, run `terraform apply`.
Terraform outputs the CNAME records to add in Squarespace DNS for cert validation.
Run `terraform apply` once more after adding them — HTTP will redirect to HTTPS automatically.

---

## Branch Protections

Both `dev-deploy` and `prod-deploy` are protected in GitHub:

- ✅ Require a pull request before merging
- ✅ No required approvals (any team member can merge their own PR)
- ✅ Applies to admins too (no bypass)

---

## Rollback

```bash
# List recent task definition revisions
aws ecs list-task-definitions --family-prefix ejam --sort DESC \
  --query 'taskDefinitionArns[:5]' --output text

# Roll back prod
aws ecs update-service --cluster ejam-prod-cluster \
  --service ejam-prod-service --task-definition ejam:<REVISION>

# Roll back dev
aws ecs update-service --cluster ejam-dev-cluster \
  --service ejam-dev-service --task-definition ejam-dev:<REVISION>
```

---

## Debug

```bash
# Tail latest logs (prod)
aws logs get-log-events \
  --log-group-name /ecs/ejam-prod \
  --log-stream-name $(aws logs describe-log-streams \
    --log-group-name /ecs/ejam-prod --order-by LastEventTime \
    --descending --limit 1 \
    --query 'logStreams[0].logStreamName' --output text) \
  --limit 50 --region us-east-1 \
  --query 'events[*].message' --output text

# Filter for errors (last 30 min)
aws logs filter-log-events \
  --log-group-name /ecs/ejam-prod \
  --filter-pattern "Error" \
  --start-time $(($(date -v-30M +%s) * 1000)) \
  --query 'events[*].message' --output text

# Check service health
aws ecs describe-services \
  --cluster ejam-prod-cluster --services ejam-prod-service \
  --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
```
