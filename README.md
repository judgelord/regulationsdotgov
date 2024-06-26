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

- `get_dockets("[agency_acronym]")` retrieves dockets for an agency (see official acronyms on regulations.gov)

#### Get documents from a docket folder

- `get_documents("[docket_id]")` retrieves documents for a docket 

#### Get metadata for comments on a document or docket

- `get_commentsOnId("[docket_id]")` retrieves all comments for a docket (e.g., including an Advanced Notice of Proposed Rulemaking and all draft proposed rules)

- `get_commentsOnId("[document_id]")` retrieves comments on a specific document (e.g., a specific proposed rule)

#### Get detailed metadata about a comment 

`get_comment_details("[comment_id]")` retrieves comments on a specific document (e.g., a specific proposed rule)

## Search

The package also contains functions to use the API's search function to search the text of documents or comments: 

- `get_searchTerm(searchTerm = "[searchTerm]", documents = c("documents", "comments"), agency_acronym = c("all", "[agency_acronym]"), docket_id = c("all", "[docket_id]")  )` 
 
## Download

Finally, using URLs returned from `get_documents()` and `get_comment_details()`, we can download files  (e.g., pdfs)

- `download_regulationsdotgov("[url]")` saves local copies of desired files in a standard file structure mirroring that above in a "files" folder: "files/agency_acronym/docket_id/document_id/document_name.extension"  (e.g., "files/ACF/ACF-2009-0005/ACF-2009-0005-0018/attachment_1.doc" is a public comment on notice "files/ACF/ACF-2009-0005//ACF-2009-0005-0002/content.pdf")

To specify your own file structure, simply use the base download function 

- `download.file(url = "[url]", destfile = "[path]")` 


## Important notes 

- To use `regulationsdotgov,` you will need an API key. These keys have limits. You can request a rate increase. 

- The functions are currently built with the theory that the user wants all results for a given agency/docket/document. While not highlighted in the documentation, a user can limit the search to results *before* a given date with a `lastModifiedDate` argument (API calls are curently hard-coded to be in decending order). In the future, we will add more options to restrict results to a given timeframe. 



