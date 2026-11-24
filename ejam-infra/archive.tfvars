environment                    = "archive"
domain_name                    = ""             # set to custom domain when ready (e.g. "ejam.yourdomain.com")
task_family                    = "ejam-archive"
task_cpu                       = 2048           # 2 vCPU - as requested in issue # 686
task_memory                    = 7168           # 7 GB - as requested in issue # 686
desired_count                  = 1
manage_ecr                     = false          # shares prod's ECR repo; prod Terraform owns it
create_ecs_service_linked_role = false          # account-wide role already exists from prod
deletion_protection            = false          # allow easy teardown - set this to true once we're solid on the launch
log_retention_days             = 30             # as requested in issue # 686
container_insights             = "enabled"      # as requested in issue # 686

