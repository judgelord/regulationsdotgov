# `regulationsdotgov`

a package to get data from regulations.gov

## Metadata

Regulations.gov metadata is organized in a hierarchical database.

- Agencies
  - Dockets are "folders" where agencies keep documents for each policymaking process  (including rulemaking and non-rulemaking dockets)
    - Documents (including proposed rules, rules, and supplementary materials)
      - Comments on those documents (high-level metadata)
        - Comment Details for each comment (detailed metadata)

The `regulationsdotgov` package is organized with a parallel set of functions to retrieve metadata: 

#### Get dockets from an agency

`get_dockets("[agency_acronym]")` retrieves dockets for an agency (see official acronyms on regulations.gov)

#### Get documents from a docket folder

`get_documents("[docket_id]")` retrieves documents for a docket 

#### Get metadata for comments on a document or docket

`get_commentsOnId("[docket_id]")` retrieves all comments for a docket (e.g., including an Advanced Notice of Proposed Rulemaking and all draft proposed rules)

`get_commentsOnId("[document_id]")` retrieves comments on a specific document (e.g., a specific proposed rule)

#### Get detailed metadata about a comment 

`get_comment_details("[comment_id]")` retrieves comments on a specific document (e.g., a specific proposed rule)

## Search

The package also contains functions to use the API's search function to search the text of documents or comments: 

`get_searchTerm(searchTerm = "[searchTerm]", documents = c("documents", "comments"") )` 
 
## Download

Finally, using URLs returned from `get_documents()` and `get_comment_details()`, the `download()` function will save local copies of desired files (e.g., pdfs) in a standard file structure. 


## Important notes 

To use `regulationsdotgov,` you will need an API key. These keys have limits. You can request a rate increase. 

- Downloaded files will appear in a file structure mirroring that above in a "files" folder: "files/agency_acronym/docket_id/document_id/" and be named with their document_id or comment_id (e.g., )






