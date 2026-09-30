# EJAM web app deploy branch

This branch holds only the files that build and deploy the EJAM Shiny web app
to AWS ECS Fargate. It does not hold the EJAM package source. The `Dockerfile`
installs EJAM from GitHub at the ref in `ARG EJAM_VERSION`, and downloads the
`ejamdata` release named in `ARG EJAMDATA_VERSION`.

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the app image; pins `EJAM_VERSION` and `EJAMDATA_VERSION` |
| `.github/workflows/deploy-dev.yaml` | Builds and deploys to **dev** (on push to `dev-deploy`, or run manually with an optional `ejam_version`) |
| `.github/workflows/deploy.yaml` | Builds and deploys to **prod** (on push to `prod-deploy`, or run manually) |
| `.github/workflows/diag-ecs-dev.yaml` | Read-only diagnostics for the dev ECS service (run manually) |
| `ejam-infra/` | Terraform for the AWS infrastructure |

**Merging a pull request into `dev-deploy` or `prod-deploy` deploys immediately.**

The full procedure (changing the pins, running the dev deploy for another EJAM
ref, rollback, logs) is in the article
[Deploying the Web App to AWS](https://public-environmental-data-partners.github.io/EJAM/dev/articles/dev-deployment.html),
whose source is `vignettes/dev-deployment.Rmd` on the `development` branch.
