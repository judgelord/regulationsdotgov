# Retrieve Full Document Details and Metadata

Fetches complete document details and metadata from regulations.gov
using document IDs. Returns a data frame containing the full document
information, including title, abstract, dates, and all associated
metadata fields.

## Usage

``` r
get_document_details(id, lastModifiedDate = Sys.time(), api_keys)
```

## Arguments

- id:

  Character string or vector containing document ID(s) obtained from
  [`get_documents`](https://judgelord.github.io/regulationsdotgov/reference/get_documents.md)
  or other search functions. Duplicate IDs are automatically removed to
  optimize API usage.

- lastModifiedDate:

  Filter documents by their last modified date. Default is current
  system time. Format must be: `"yyyy-MM-dd%20HH:mm:ss"` (e.g.,
  "2024-01-01%2000:00:00" for January 1, 2024).

- api_keys:

  Character string or vector containing API key(s) from api.data.gov. If
  multiple keys are provided, the function will cycle through them to
  manage rate limits.

## Details

This function retrieves the complete metadata for regulatory documents,
including Federal Register notices, proposed rules, final rules, and
supporting materials. Unlike
[`get_documents`](https://judgelord.github.io/regulationsdotgov/reference/get_documents.md)
which returns summary information, this function fetches the full
detailed record from the regulations.gov API.

If the function encounters errors during execution, it will save
successfully retrieved documents to a temporary .rda file and provide
the file path for recovery.

## References

Regulations.gov API Documentation:
<https://open.gsa.gov/api/regulationsgov/>

## Examples

``` r
if (FALSE) { # \dontrun{
# Get details for a single document using its ID
doc_details <- get_document_details(
  id = "EPA-HQ-OAR-2025-1806-0001", 
  api_keys = "DEMO_KEY"
)

# View the document abstract
cat(doc_details$abstract)

# Get details for multiple documents
doc_ids <- c("EPA-HQ-OAR-2025-1806-0001", 
             "ED-2022-OPE-0157-0001")
             
multiple_docs <- get_document_details(
  id = doc_ids, 
  api_keys = "DEMO_KEY"
)

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_document_details(
  id = doc_ids, 
  api_keys = keys
)

# Typical workflow: get summary first, then full details
# Get summary metadata for all documents in a docket
summary <- get_documents(docketId = "ED-2022-OPE-0157", 
                        api_keys = "DEMO_KEY")
                        
# Then fetch full details for specific documents of interest
detailed <- get_document_details(
  id = summary$id, 
  api_keys = "DEMO_KEY"
)
} # }
```
