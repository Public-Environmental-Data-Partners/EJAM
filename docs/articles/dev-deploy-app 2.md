# Deploying the Web App

## Hosting the Web App

These issues might be relevant to deploying/hosting:

### Consider the isPublic parameter

Consider the `isPublic` parameter as set in the file app.R – The
`isPublic` flag determined whether to show the public/basic or expert
version of the web application. See the help in
[`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md)
and for more details see [Defaults and Custom Settings for the Web
App](https://ejanalysis.github.io/EJAM/articles/dev-app-settings.md).
One way to improve this process would be to modify the `isPublic` toggle
to be an environment variable. This would allow us to set the value once
in each application server, and not have to change it each time we push
updates. Moreover, it would make testing the app easier to handle in the
GitHub actions (see [shinytests
vignette](https://ejanalysis.github.io/EJAM/articles/dev-run-shinytests.md)).
Note that after mid-2025 the isPublic setting is defined in the file
app.R and has been handled as explained in the article [Defaults and
Custom Settings for the Web
App](https://ejanalysis.github.io/EJAM/articles/dev-app-settings.md).

### Consider other parameters

Consider the other parameters like logo-related and app title
parameters, defined in the files `global_defaults_package.R` or
`global_defaults_shiny.R`. See the help in
[`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md)
and for more details see [Defaults and Custom Settings for the Web
App](https://ejanalysis.github.io/EJAM/articles/dev-app-settings.md).

### Update EJAM Application

Update the app. See [Updating the Package as a New
Release](https://ejanalysis.github.io/EJAM/articles/dev-update-package.md)
vignette.

### Decide which branch to deploy from

Update the branch from which the app will be deployed, which could be a
different branch, such as “deploy-from” if that is useful.

### Deploy via Docker, AWS, Posit Connect/Cloud, or whatever approach you prefer

#### 1. Using Docker/AWS for hosting

The live EJAM app in 2025 was being hosted via AWS and Docker using the
Dockerfile now included with the EJAM package, and is hosted at a URL
you can be directed to from this shortcut:
<https://ejanalysis.org/ejamapp> The EJAM fork at
<https://github.com/Environmental-Policy-Innovation-Center/ejam-mc-pedp>
shows how the deployment works, but essentially it is based on the
Dockerfile.

The [EJAM-API](https://github.com/edgi-govdata-archiving/EJAM-API) is
deployed via Docker as well, and that repository shows how the
deployment works.

The EPA-hosted (pre-2025) app used [Posit
Connect](https://posit.co/products/enterprise/connect/) for hosting.

#### 2. Using Posit Connect (or Posit ConnectCloud) for Hosting

Shiny apps can be hosted using [Posit
Connect](https://posit.co/products/enterprise/connect/) or [Posit
Connect Cloud](https://connect.posit.cloud), which are commercial
products that have a full set of features focused on hosting shiny apps
and APIs based on R/Python.

- Configure Posit Connect to deploy from a github.com repository - The
  EPA-hosted (pre-2025) app used a [Posit Connect server configured to
  re-publish the shiny app directly from github.com
  content](https://docs.posit.co/connect/user/git-backed/) whenever it
  saw changes in the specified repo and branch, and [that same
  approach](https://posit.co/blog/git-backed-deployment-in-posit-connect/)
  could be used by anyone else hosting the app.

- Handle dependencies with Posit Connect - Posit Connect uses the
  rsconnect package and tracks where each package was installed from,
  including EJAM itself, so EJAM should be installed from github. See
  notes on doing that, in the file
  EJAM/data-raw/rsconnect-manifest-update.R Also note that if the renv
  package is being used to handle dependencies then publishing to Posit
  Connect has to take that into account as explained here:
  <https://rstudio.github.io/renv/articles/rsconnect.html>

- Update the `manifest.json` file to deploy to Posit Connect/Cloud - If
  using Posit, use a script like
  `EJAM/data-raw/rsconnect_manifest_update.R` to update the manifest
  file.
