# EJScreen dataset-creator input field order

EJScreen dataset-creator input field order

## Usage

``` r
ejscreen_dataset_creator_input_fields()
```

## Value

character vector of EJScreen Python input field names.

## Details

These are the input columns expected by the EPA
`ejscreen-dataset-creator-2.3` Python tool, based on its `col_names.py`
lists `info_names`, `data_names`, and `extra_cols`. This is
intentionally smaller than `ejscreen_feature_server_fields()` because
the Python tool calculates EJ indexes, percentiles, map bins, and map
text itself.
