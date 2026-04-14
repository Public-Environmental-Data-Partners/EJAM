# utility for server/ui to check value of a global default setting or user-defined setting

utility for server/ui to check value of a global default setting or
user-defined setting

## Usage

``` r
global_or_param(vname)
```

## Arguments

- vname:

  a global default or user param - do a global find in files of source
  code for this function to see how / where it is used.

## Value

value of the param, or NULL if not found

## Details

This and
[`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html)
are very similar tools, useful in server and ui. See help for
[`get_global_defaults_or_user_options()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_global_defaults_or_user_options.md)

`global_or_param()` is used a lot in server and also ui (while sometimes
[`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html)
had been used instead but now is not, for the same purpose). It is used
generally in ui to set default values for params that are set in the
global_defaults\_ files and often can be modified in the advanced tab.
To provide alternative values as params passed to
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
you would have to understand the options by seeing what they are
defaulted to in the files and how they are used as parameters in ui or
server. See
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)

This is much like
[`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html)
but `global_or_param()` is more flexible/robust since it will, if vname
is not already defined as found by
[`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html)

then as second best, see if it was defined in global_defaults_package
and just not yet stored as golem options because the shiny app has not
yet launched. That lets any function or vignette find the values defined
in global_defaults_package.R even if a shiny app has not yet launched.

Then as a last resort, check if the param called vname is defined in the
calling envt already somehow, and return that value if it exists. But if
it is not in golem options and not found, this returns NULL
