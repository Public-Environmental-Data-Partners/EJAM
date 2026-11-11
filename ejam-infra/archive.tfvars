environment                    = "archive"
domain_name                    = ""             # set to custom domain when ready (e.g. "ejam.yourdomain.com")
task_family                    = "ejam-archive"
task_cpu                       = 1024           # 1 vCPU
task_memory                    = 6144           # 6 GB (EJAM needs ~500MB+ for arrow data at startup)
desired_count                  = 1
manage_ecr                     = false          # shares prod's ECR repo; prod Terraform owns it
create_ecs_service_linked_role = false          # account-wide role already exists from prod
deletion_protection            = false          # allow easy teardown
log_retention_days             = 7
container_insights             = "disabled"     # saves ~$5/mo on an archive environment

