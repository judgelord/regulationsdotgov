# Get documents from a docket folder

get_documents("\[docketId\]") retrieves metadata for all documents
belonging to a docket

## Usage

``` r
get_documents(docketId, lastModifiedDate, api_keys)
```

## Arguments

- docketId:

  ID of docket

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
# FBI_docket_2024 <- get_documents(docketId = "FBI-2024-0001", api_keys = "DEMO_KEY")

# head(FBI_docket_2024)

# A tibble: 1 × 16
#   documentType lastModifiedDate     highlightedContent frDocNum   withdrawn agencyId # commentEndDate     title
#   <chr>        <chr>                <chr>              <chr>      <lgl>     <chr>    <chr>       #        <chr>
# 1 Rule         2024-07-26T01:01:24Z ""                 2024-14253 FALSE     FBI      2024-08# -01T03:59:… Bipa…
# ℹ 8 more variables: postedDate <chr>, docketId <chr>, subtype <lgl>, commentStartDate <chr>,
#   openForComment <lgl>, objectId <chr>, id <chr>, lastpage <lgl>
```
