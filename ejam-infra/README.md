# EJAM Infrastructure

Terraform config for EJAM on AWS ECS Fargate. Supports `prod` and `dev` environments
from a single parameterized `main.tf` using separate `.tfvars` files and separate S3 state keys.

## Prerequisites

- Terraform >= 1.5
- AWS credentials with ECS/ECR/VPC/IAM permissions
- S3 state bucket: `ejam-terraform-state-716228812058` (already created)

## First-time setup — migrate prod state to S3

The prod environment was initially applied with local state. Migrate it once:

```bash
cd ejam-infra

terraform init \
  -backend-config="key=prod/terraform.tfstate" \
  -reconfigure
# Terraform will ask: "Do you want to copy existing state to the new backend?" → yes
```

## Applying changes

### Prod
```bash
terraform init -backend-config="key=prod/terraform.tfstate"
terraform plan  -var-file=prod.tfvars -var="aws_account_id=716228812058"
terraform apply -var-file=prod.tfvars -var="aws_account_id=716228812058"
```

### Dev (first time — creates all dev AWS resources)
```bash
terraform init -backend-config="key=dev/terraform.tfstate" -reconfigure
terraform plan  -var-file=dev.tfvars -var="aws_account_id=716228812058"
terraform apply -var-file=dev.tfvars -var="aws_account_id=716228812058"
```

After the dev apply, note the `alb_dns_name` output — that's your dev app URL.
Update `deploy-dev.yaml` env vars with the cluster/service names from the output.

## Environment differences

| Setting              | Prod        | Dev         |
|----------------------|-------------|-------------|
| ECS task family      | `ejam`      | `ejam-dev`  |
| vCPU                 | 2           | 1           |
| Memory               | 7 GB        | 6 GB        |
| Tasks (desired)      | 2           | 1           |
| ECR repo             | owned       | shared (read-only) |
| ALB deletion protect | yes         | no          |
| Log retention        | 30 days     | 7 days      |
| Container Insights   | enabled     | disabled    |

## Rollback

To roll back to a previous ECS task definition revision:

```bash
# List recent revisions
aws ecs list-task-definitions --family-prefix ejam --sort DESC --query 'taskDefinitionArns[:5]'

# Roll back prod to a specific revision
aws ecs update-service \
  --cluster ejam-prod-cluster \
  --service ejam-prod-service \
  --task-definition ejam:<REVISION_NUMBER>

# Roll back dev
aws ecs update-service \
  --cluster ejam-dev-cluster \
  --service ejam-dev-service \
  --task-definition ejam-dev:<REVISION_NUMBER>
```
