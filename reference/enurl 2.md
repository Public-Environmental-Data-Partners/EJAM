# Create an url

Create an url

## Usage

``` r
enurl(url, text)
```

## Arguments

- url:

  the URL

- text:

  the text to display

## Value

a tag, with "shiny.tag" class: class(enurl("google.com", "click here"))

## See also

[`url_linkify()`](https://ejanalysis.github.io/EJAM/reference/url_linkify.md)

## Examples

``` r
EJAM:::enurl("https://www.thinkr.fr", "ThinkR")
```
