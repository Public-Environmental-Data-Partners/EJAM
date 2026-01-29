# Convert surface distance to actual distance

    \preformatted{
        Just a simple formula:
       earthRadius_miles <- 3959
       angle_rad <- x/earthRadius_miles
       # Calculate  radius * cord length
       return( earthRadius_miles * 2*sin(angle_rad/2) )
       }

## Usage

``` r
distance_via_surfacedistance(x)
```

## Arguments

- x:

  surface distance in miles
