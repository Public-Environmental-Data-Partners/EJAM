# utility - interactive prompt in RStudio to ask user to specify number like radius

same as askradius()

## Usage

``` r
ask_number(
  default = 3,
  title = "Radius",
  message = "Within how many miles of each point?"
)
```

## Arguments

- default:

  default value for the number to be provided and returned

- title:

  title of popup dialog box, like "Radius"

- message:

  question, like, "Within how many miles of each point?"

## Value

a single number

## See also

askYesNo()
