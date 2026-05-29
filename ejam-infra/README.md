# EJAM Infrastructure & Deployment

> AWS ECS Fargate hosting for the EJAM R Shiny app.
> Two environments — **prod** and **dev** — each deployed via GitHub Actions on push to their respective protected branches.

---

## Deploying Changes

### Branching model

```
feature / fix branch
        │
        ▼
      main  ──── PR ────►  dev-deploy  ──── PR ────►  prod-deploy
                          (validate here)              (production)
```

### Step-by-step

**1. Get your changes into `main`**
Open a PR from your feature/fix branch → `main` and merge as normal.

**2. Deploy to dev**
Open a PR from `main` → `dev-deploy`. Requires approval from a repo admin.
Once merged, GitHub Actions builds the Docker image and deploys to the dev environment automatically (~15 min build).

**3. Validate on dev**
Test your changes at the dev URL. Green-light from a human required before promoting to prod.

**4. Deploy to prod**
Open a PR from `dev-deploy` → `prod-deploy` (or `main` → `prod-deploy` for urgent fixes). Requires approval from a repo admin.
Once merged, GitHub Actions deploys to production automatically.

> **Branch protections:** Both `dev-deploy` and `prod-deploy` require a PR — direct pushes are blocked for all users including admins. See [Setting up branch protections](#branch-protections) below.

---

## URLs

| Environment | URL |
|---|---|
| Production | http://ejam-prod-alb-833585434.us-east-1.elb.amazonaws.com |
| Dev | http://ejam-dev-alb-971929002.us-east-1.elb.amazonaws.com |

---

## Branch Protections

Both `dev-deploy` and `prod-deploy` should be protected in GitHub:

**Settings → Branches → Add rule** for each branch:
- ✅ Require a pull request before merging
- ✅ Required approvals: 1 (restrict to repo admins via CODEOWNERS or team)
- ✅ Do not allow bypassing the above settings (applies to admins too)
- ✅ Require status checks to pass (optional but recommended)

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
terraform apply -var-file=dev.tfvars  -var="aws_account_id=716228812058"
```

### Adding a custom domain (HTTPS)
Set `domain_name = "ejam.yourdomain.com"` in `prod.tfvars`, run `terraform apply`.
Terraform outputs the CNAME records to add in Squarespace DNS for cert validation.
Run `terraform apply` once more after adding them — HTTP will redirect to HTTPS automatically.

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
