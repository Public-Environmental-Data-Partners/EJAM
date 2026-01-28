# utility that reconciles/ consolidates user-defined params passed via ejamapp() and settings from global_defaults\_ files

utility that reconciles/ consolidates user-defined params passed via
ejamapp() and settings from global_defaults\_ files

## Usage

``` r
get_global_defaults_or_user_options(
  user_specified_options = NULL,
  bookmarking_allowed = "url"
)
```

## Arguments

- user_specified_options:

  named list of any optional arguments that were in the call to
  [`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md)

- bookmarking_allowed:

  same as [shiny::shinyApp](https://rdrr.io/pkg/shiny/man/shinyApp.html)
  enableBookmarking param

## Value

a list of global defaults or user options that
[`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md)
uses as the golem_opts parameter in
[`golem::with_golem_options()`](https://thinkr-open.github.io/golem/reference/with_golem_options.html)
and that later can be retrieved by server or ui via
[`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html)
or via
[`global_or_param()`](https://ejanalysis.github.io/EJAM/reference/global_or_param.md)
(which both do almost the same thing).

## Details

This function, called by
[`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md),
collects the shiny-app-related default settings that are defined in
these places:

1.  any options a user has passed as parameters to
    [`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md).
    If provided, these override defaults specified in
    global_defaults\_\*.R files.

2.  "global_defaults_package" set in file `global_defaults_package.R` –
    sourced here but also initially by
    [`.onAttach()`](https://rdrr.io/r/base/ns-hooks.html)

3.  global defaults set in file `global_defaults_shiny.R` – sourced here

4.  global defaults set in file `global_defaults_shiny_public.R` – and
    in that file, depends on value of isPublic if passed as a param to
    [`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md)

and consolidates them all as a list, to be available to server/ui.

For more details, see the [article about defaults and custom
settings](https://ejanalysis.github.io/EJAM/articles/).

See other ideas for how to include global.R types of code/settings
discussed [here](https://github.com/ThinkR-open/golem/issues/6)
