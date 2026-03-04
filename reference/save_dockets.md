# Save docket metadata in directory.

save_dockets("\[agency_acronym\]") creates a data directory for
collecting agency docket metadata within a folder structure.

## Usage

``` r
save_dockets(agency)
```

## Arguments

- agency:

  Agency acronym(s) (see official acronyms on regulations.gov)

## Details

This function uses the get_dockets function internally, so you will need
to have an 'api_keys' stored in your environment in order for it to
function properly.

## Value

Stores data as a .rmd file.

## References

## Author

## Note

## See also

## Examples

``` r
agency <- c("OMB")

save_dockets(agency)
#> get_dockets for OMB
#> An error occurred: argument "api_keys" is missing, with no default
#> | OMB | n = 0 |
```
