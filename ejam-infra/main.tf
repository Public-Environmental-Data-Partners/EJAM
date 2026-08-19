###############################################################################
# EJAM R Shiny App — AWS Infrastructure (Fargate)
#
# Supports both prod and dev environments via .tfvars files.
#
# Resources created:
#   - VPC + public subnets + IGW
#   - ALB + target group + listener
#   - ECR repository (prod only; dev shares prod's repo)
#   - ECS cluster (Fargate) + service + task definition
#   - IAM roles (execution + task)
#   - Security groups
#   - CloudWatch log group
#
# Usage:
#   # First time setup — migrate local state to S3:
#   terraform init \
#     -backend-config="key=prod/terraform.tfstate" \
#     -reconfigure
#
#   # Subsequent prod applies:
#   terraform init -backend-config="key=prod/terraform.tfstate"
#   terraform plan  -var-file=prod.tfvars -var="aws_account_id=<ACCOUNT_ID>"
#   terraform apply -var-file=prod.tfvars -var="aws_account_id=<ACCOUNT_ID>"
#
#   # Dev applies (separate state, separate AWS resources):
#   terraform init -backend-config="key=dev/terraform.tfstate" -reconfigure
#   terraform plan  -var-file=dev.tfvars -var="aws_account_id=<ACCOUNT_ID>"
#   terraform apply -var-file=dev.tfvars -var="aws_account_id=<ACCOUNT_ID>"
###############################################################################

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Partial backend config — supply `key` at init time via -backend-config flag.
  # Bucket must be created manually before first init (see README.md).
  backend "s3" {
    bucket  = "ejam-terraform-state-716228812058"
    region  = "us-east-1"
    encrypt = true
    # key is passed at init time:
    #   prod: -backend-config="key=prod/terraform.tfstate"
    #   dev:  -backend-config="key=dev/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_account_id" {
  description = "Your AWS account ID (used for ECR URI)"
  type        = string
}

variable "app_name" {
  default = "ejam"
}

variable "environment" {
  description = "Environment name: prod or dev"
  default     = "prod"
}

variable "task_family" {
  description = "ECS task definition family name. Use 'ejam' for prod (backward compat), 'ejam-dev' for dev."
  default     = "ejam"
}

variable "app_port" {
  default = 2000
}

variable "health_check_port" {
  default = 2001
}

variable "health_check_grace_period_seconds" {
  description = "How long ECS ignores ALB health-check failures after a task starts. The container CMD starts the port-2001 health endpoint in the same R process as the Shiny app, so it cannot answer until R finishes loading EJAM + arrow data; with the default of 0, the ALB (30s interval x 3 unhealthy = ~90s) kills slow-booting tasks before they are ready. Grace only suppresses health-check kills during startup - a crashed container still stops immediately."
  default     = 300
}

variable "task_cpu" {
  description = "Fargate task CPU units (1024 = 1 vCPU)"
  default     = 2048
}

variable "task_memory" {
  description = "Fargate task memory in MB"
  default     = 7168
}

variable "desired_count" {
  default = 2
}

# Extra environment variables injected into the app container, as a map.
#
# This is what lets two vintages run side by side: each environment's tfvars can
# point its app at its own API without any further Terraform change. For example
# a 2024-vintage environment would set
#
#   app_env_vars = { EJAM_API_BASEURL = "https://api2024.ejanalysis.com" }
#
# while the 2022-vintage environment leaves it unset and keeps the DESCRIPTION
# default. EJAM reads this via url_package("api"), whose precedence is
# options(ejam.api.baseurl) > EJAM_API_BASEURL > DESCRIPTION > hardcoded.
#
# Terraform iterates a map in lexical key order, so the rendered list is stable
# and an unchanged map produces no diff. The default is empty, which renders as
# `environment = []` - the same as the current task definition, so adding this
# variable changes nothing until a tfvars file sets it.
variable "app_env_vars" {
  description = "Environment variables for the app container (name => value)"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "deletion_protection" {
  description = "Enable ALB deletion protection. Set false for dev so it can be torn down easily."
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  default     = 30
}

variable "container_insights" {
  description = "ECS Container Insights: 'enabled' or 'disabled'. Disable for dev to save cost."
  default     = "enabled"
}

variable "create_ecs_service_linked_role" {
  description = "Set true only on first deploy to a fresh AWS account. The role is account-wide and only needs to be created once across all environments."
  default     = false
}

variable "manage_ecr" {
  description = "Set true for prod (creates and owns the ECR repo). Set false for dev (dev shares the prod ECR repo via data source)."
  default     = true
}

variable "domain_name" {
  description = "Custom domain for the app (e.g. ejam.yourdomain.com). Leave empty until domain is confirmed. When set, an ACM certificate is requested and an HTTPS listener is added to the ALB. HTTP traffic is redirected to HTTPS."
  default     = ""
}

locals {
  name_prefix  = "${var.app_name}-${var.environment}"
  azs          = ["${var.aws_region}a", "${var.aws_region}b"]
  public_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

# -----------------------------------------------------------------------------
# NETWORKING
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.name_prefix}-igw" }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public-${count.index}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${local.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# SECURITY GROUPS
# -----------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-alb-sg" }
}

resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${local.name_prefix}-ecs-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port       = var.health_check_port
    to_port         = var.health_check_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-ecs-sg" }
}

# -----------------------------------------------------------------------------
# ALB
# -----------------------------------------------------------------------------

resource "aws_lb" "main" {
  name                       = "${local.name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = var.deletion_protection

  tags = { Name = "${local.name_prefix}-alb" }
}

resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = tostring(var.health_check_port)
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }

  # Keep each user pinned to one container for the life of their visit.
  #
  # Shiny keeps session state in the memory of a single R process, and a file
  # upload arrives as a SEPARATE HTTP POST from the page load. Without this,
  # the load balancer round-robins that POST to the other container, which has
  # never heard of the session and answers 404 "<h1>Not Found</h1>" -- rendered
  # unescaped in the app's red upload bar. See EJAM#268.
  #
  # This must stay in Terraform: the same fix was applied by hand in the AWS
  # console in Feb 2026, was never codified here, and was silently lost.
  # Only matters where desired_count > 1 (prod is 2, dev is 1), but it is set
  # for both so dev cannot drift away from prod behavior.
  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400 # seconds (1 day); ALB max is 604800
  }

  tags = { Name = "${local.name_prefix}-tg" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # When a domain is configured, redirect HTTP → HTTPS.
  # Otherwise forward directly to the app.
  default_action {
    type = var.domain_name != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.domain_name != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.domain_name != "" ? null : aws_lb_target_group.app.arn
  }
}

# -----------------------------------------------------------------------------
# ACM + HTTPS — only created when domain_name is set
# -----------------------------------------------------------------------------

resource "aws_acm_certificate" "app" {
  count             = var.domain_name != "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "${local.name_prefix}-cert" }
}

# Output the DNS validation records so they can be added to Squarespace
output "acm_validation_cnames" {
  description = "Add these CNAME records in Squarespace DNS to validate the ACM certificate. Only populated when domain_name is set."
  value = var.domain_name != "" ? {
    for dvo in aws_acm_certificate.app[0].domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  } : {}
}

resource "aws_acm_certificate_validation" "app" {
  count           = var.domain_name != "" ? 1 : 0
  certificate_arn = aws_acm_certificate.app[0].arn
  # DNS validation — add the CNAME records from acm_validation_cnames output
  # to Squarespace, then re-run terraform apply to complete validation.
}

resource "aws_lb_listener" "https" {
  count             = var.domain_name != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.app[0].certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# -----------------------------------------------------------------------------
# ECR
# Prod owns and manages the ECR repository.
# Dev shares prod's repository (manage_ecr = false) — URL is derived from
# known values to avoid requiring ecr:DescribeRepositories/DescribeImages
# permissions on the Terraform user.
# -----------------------------------------------------------------------------

resource "aws_ecr_repository" "app" {
  count                = var.manage_ecr ? 1 : 0
  name                 = var.app_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "${local.name_prefix}-ecr" }
}

resource "aws_ecr_lifecycle_policy" "app" {
  count      = var.manage_ecr ? 1 : 0
  repository = aws_ecr_repository.app[0].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images older than 10"
      selection = {
        tagStatus   = "untagged"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

locals {
  # When manage_ecr = true (prod), use the resource URL.
  # When manage_ecr = false (dev), construct the URL from known values —
  # avoids needing ecr:DescribeRepositories/DescribeImages on the Terraform user.
  ecr_repository_url = var.manage_ecr ? aws_ecr_repository.app[0].repository_url : "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_name}"
}

# -----------------------------------------------------------------------------
# IAM
# -----------------------------------------------------------------------------

# ECS service-linked role — account-wide, only needed once on a fresh account.
# Set create_ecs_service_linked_role = true only if this is the first ECS deployment
# in this AWS account. Leave false if the role already exists.
resource "aws_iam_service_linked_role" "ecs" {
  count            = var.create_ecs_service_linked_role ? 1 : 0
  aws_service_name = "ecs.amazonaws.com"

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_iam_role" "ecs_execution" {
  name = "${local.name_prefix}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# -----------------------------------------------------------------------------
# CLOUDWATCH LOGS
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  tags              = { Name = "${local.name_prefix}-logs" }
}

# -----------------------------------------------------------------------------
# ECS CLUSTER + SERVICE
# -----------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.container_insights
  }

  tags = { Name = "${local.name_prefix}-cluster" }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = "${local.ecr_repository_url}:latest"
    essential = true

    portMappings = [
      { containerPort = var.app_port,          protocol = "tcp" },
      { containerPort = var.health_check_port, protocol = "tcp" }
    ]

    environment = [for k, v in var.app_env_vars : { name = k, value = v }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "app" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }

  # Allow GitHub Actions to update the task definition without Terraform fighting it
  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [aws_lb_listener.http]
}

# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------

output "alb_dns_name" {
  description = "Public URL for the app"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repo URL — use in GitHub Actions"
  value       = local.ecr_repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}
