# Clean raw output of doaggregate() from the EJAM package

Takes the raw output version of batch buffer results and cleans it up to
make it ready for batch.summarize function Note this drops rows with no
pop data - assumes those lack EJSCREEN batch results

## Usage

``` r
batch.clean(x, namesfile = "keepnames", oldcolnames, newcolnames)
```

## Arguments

- x:

  Required. output of batch processor that runs EJSCREEN report once per
  site.

- namesfile:

  Optional but must specify either namesfile, or both oldcolnames and
  newcolnames. A csv filename, of file that maps fieldnames from those
  in raw output of batch processor to more useful and clear names that
  make more sense. If function is called with the special value
  namesfile='keepnames' then the names are unchanged from those in x.

- oldcolnames:

  Optional. The names to be found in x, ignored if namesfile specified.

- newcolnames:

  Optional. The corresponding names to change them to, ignored if
  namesfile specified.
