# utility - check if URL available, such as if an API is online or offline

utility - check if URL available, such as if an API is online or offline

## Usage

``` r
url_online(url = "https://ejam.policyinnovation.info")
```

## Arguments

- url:

  the URL to check

## Value

TRUE or FALSE (but NA if no internet connection seems to be available at
all)

## Details

Also see EJAM:::global_or_param("ejamapi_is_down") as set in
global_defaults_package.R
