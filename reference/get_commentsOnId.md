# Retrieve Comments on a Specific Document or from an Agency

Fetches comment metadata from regulations.gov. Can retrieve all comments
on a specific document using its objectId, or all comments submitted to
an agency. Returns a data frame containing comment details based on
specified filters.

## Usage

``` r
get_commentsOnId(objectId = NULL, agencyId = NULL, 
                 lastModifiedDate = Sys.time(), 
                 lastModifiedDate_mod = "le", 
                 api_keys)
```

## Arguments

- objectId:

  Optional character string containing the objectId from a document's
  metadata. When provided, returns all comments on that specific
  document. Must specify either `objectId` or `agencyId`.

- agencyId:

  Optional character string containing the agency acronym. When
  provided, returns all comments submitted to the specified agency. Must
  specify either `objectId` or `agencyId`. Must match official agency
  acronyms used on regulations.gov (e.g., "EPA", "FCC", "CMS").

- lastModifiedDate:

  Filter comments by their last modified date. Default is current system
  time. Format must be: `"yyyy-MM-dd%20HH:mm:ss"` (e.g.,
  "2024-01-01%2000:00:00" for January 1, 2024).

- lastModifiedDate_mod:

  Modifier for the date filter. Acceptable values:

  "le"

  :   Less than or equal to (default)

  "ge"

  :   Greater than or equal to

  NULL

  :   Collects results for a single exact date match

- api_keys:

  Character string or vector containing API key(s) from api.data.gov. If
  multiple keys are provided, the function will cycle through them to
  manage rate limits.

## References

Regulations.gov API Documentation:
<https://open.gsa.gov/api/regulationsgov/>

Agency Acronym List: <https://www.regulations.gov/agencies>

## Examples

``` r
if (FALSE) { # \dontrun{
# Get comments on a specific document using objectId
comment_metadata <- get_commentsOnId(
  objectId = "09000064865d514a", 
  api_keys = "DEMO_KEY"
)

# Get all comments submitted to the EPA
epa_comments <- get_commentsOnId(
  agencyId = "EPA",
  api_keys = "DEMO_KEY"
)

# Get comments modified after a specific date
recent_comments <- get_commentsOnId(
  agencyId = "FCC",
  lastModifiedDate = "2024-06-01%2000:00:00",
  lastModifiedDate_mod = "ge"
)

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_commentsOnId(agencyId = "EPA", api_keys = keys)
} # }
```
