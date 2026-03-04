# Search for a term

get_searchTerm("\[searchTerm\]") returns documents, comments, or dockets
filtered by specific term

## Usage

``` r
get_searchTerm(searchTerm, documents, lastModifiedDate, api_keys)
```

## Arguments

- searchTerm:

  Term to filter by.

- documents:

  Object to return. Default is set to `documents`.

  Valid options are `documents`, `comments`, or `dockets`.

- lastModifiedDate:

  Filter results by their last modified date. Default is set to
  [`Sys.time()`](https://rdrr.io/r/base/Sys.time.html).

  User-specified values must be formatted as `yyyy-MM-dd%20HH:mm:ss`.

- api_keys:

  API key(s) from api.data.gov.

## Details

## Value

## References

## Author

## Note

## See also

## Examples

``` r
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--  or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (x) 
{
  }
#> function (x) 
#> {
#> }
#> <environment: 0x55a7d95e13d8>
```
