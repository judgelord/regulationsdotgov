# Get metadata for all comments on a document

get_commentsOnId("\[objectId\]") retrieves metadata for all comments on
a document

## Usage

``` r
get_commentsOnId(objectId, agencyId, lastModifiedDate = Sys.time(), lastModifiedDate_mod, api_keys)
```

## Arguments

- objectId:

  objectId obtained from a document's metadata

  Default is set to `NULL`. User must specify either an objectId or
  agencyId.

- agencyId:

  Agency acronym (see official acronyms on regulations.gov)

  Default is set to `NULL`. User must specify either an objectId or
  agencyId.

- lastModifiedDate:

  Filter results by their last modified date. Default is set to
  [`Sys.time()`](https://rdrr.io/r/base/Sys.time.html).

  User-specified values must be formatted as `yyyy-MM-dd%20HH:mm:ss`.

- lastModifiedDate_mod:

  Parameter that modifies lastModifiedDate.

  Default is set to `lastModifiedDate_mod = "le"` to collect all results
  before current date.

  Use `lastModifiedDate_mod = NULL` to collect results for a single
  date.

  Use `lastModifiedDate_mod = "ge"` to collect results greater than a
  date.

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
# comment_metadata <- get_commentsOnId(commentOnId = "09000064865d514a", api_keys = "DEMO_KEY")

# head(comment_metadata)

# A tibble: 1 × 11
#   documentType      lastModifiedDate    highlightedContent withdrawn agencyId title objectId postedDate id   
#   <chr>             <chr>               <chr>              <lgl>     <chr>    <chr> <chr>    <chr>      <chr>
# 1 Public Submission 2024-07-26T13:29:3… ""                 FALSE     FBI      Comm… 0900006… 2024-07-2… FBI-…
# ℹ 2 more variables: lastpage <lgl>, commentOnId <chr>
```
