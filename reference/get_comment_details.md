# Retrieve Full Comment Details and Content

Fetches complete comment details and content from regulations.gov using
comment IDs. Returns a data frame containing the full text, metadata,
and attachment information for each requested comment.

## Usage

``` r
get_comment_details(id, lastModifiedDate = Sys.time(), api_keys)
```

## Arguments

- id:

  Character string or vector containing comment ID(s) obtained from
  [`get_commentsOnId`](https://judgelord.github.io/regulationsdotgov/reference/get_commentsOnId.md)
  or other search functions. Duplicate IDs are automatically removed to
  optimize API usage.

- lastModifiedDate:

  Filter comments by their last modified date. Default is current system
  time. Format must be: `"yyyy-MM-dd%20HH:mm:ss"` (e.g.,
  "2024-01-01%2000:00:00" for January 1, 2024).

- api_keys:

  Character string or vector containing API key(s) from api.data.gov. If
  multiple keys are provided, the function will cycle through them to
  manage rate limits.

## Details

This function retrieves the full content of public comments, including
the comment text, submitter information, and any attachments. Unlike
[`get_commentsOnId`](https://judgelord.github.io/regulationsdotgov/reference/get_commentsOnId.md)
which returns only metadata, this function fetches the complete comment
details from the regulations.gov API.

If the function encounters errors during execution, it will save
successfully retrieved comments to a temporary .rda file and provide the
file path for recovery.

## References

Regulations.gov API Documentation:
<https://open.gsa.gov/api/regulationsgov/>

## Examples

``` r
if (FALSE) { # \dontrun{
# Get details for a single comment using its ID
comment_details <- get_comment_details(
  id = "FBI-2024-0001-0002", 
  api_keys = "DEMO_KEY"
)

# View the full comment text
cat(comment_details$comment)

# Get details for multiple comments
comment_ids <- c("FBI-2024-0001-0002", "FBI-2024-0001-0005", 
                 "FBI-2024-0001-0007")
                 
multiple_comments <- get_comment_details(
  id = comment_ids, 
  api_keys = "DEMO_KEY"
)

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_comment_details(
  id = comment_ids, 
  api_keys = keys
)

# Typical workflow: get metadata first, then full details
# Get metadata for comments on a document
metadata <- get_commentsOnId(objectId = "09000064865d514a", 
                            api_keys = "DEMO_KEY")
# Then fetch full details for specific comments of interest
detailed <- get_comment_details(
  id = metadata$id[1:10],  # First 10 comments
  api_keys = "DEMO_KEY"
)
} # }
```
