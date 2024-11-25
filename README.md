# regulationsdotgov


<!-- README.md is generated from README.Rmd. Please edit that file -->

Get data from regulations.gov

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of regulationsdotgov from
[GitHub](https://github.com/) with:

``` r
if (!requireNamespace('pak')) install.packages('pak')
pak::pak("judgelord/regulationsdotgov")
```

``` r
library(regulationsdotgov)
```

## Metadata

Regulations.gov metadata is organized in a hierarchical database.

-   **Agencies**
    -   **Dockets** are “folders” where agencies keep documents for each
        policymaking process (including rulemaking and non-rulemaking
        dockets)
        -   **Documents** (including proposed rules, rules, and
            supplementary materials)
            -   **Comments** on those documents (high-level metadata)
                -   **Comment Details** for each comment (detailed
                    metadata)

The `regulationsdotgov` package is organized with a parallel set of
functions to retrieve metadata:

## Example: Retrieving FBI Metadata

#### Get dockets from an agency

-   `get_dockets("[agency_acronym]")` retrieves dockets for an agency
    (see official acronyms on regulations.gov)

``` r
# you need an API key
source("~/api-keys.R")

# get FBI dockets
FBI_dockets <- get_dockets(agency = "FBI", api_keys = api_keys)

head(FBI_dockets)
```

    > head(FBI_dockets)
    # A tibble: 6 × 8
       docketType    lastModifiedDate     highlightedContent agencyId title                objectId id    lastpage
      <chr>         <chr>                <lgl>              <chr>    <chr>                <chr>    <chr> <lgl>   
    1 Rulemaking    2024-08-26T13:14:32Z NA                 FBI      "Bipartisan Safer C… 0b00006… FBI-… TRUE    
    2 Rulemaking    2024-08-26T13:13:45Z NA                 FBI      "Child Protection I… 0b00006… FBI-… TRUE    
    3 Rulemaking    2023-08-25T08:08:48Z NA                 FBI      "Recently Posted FB… 0b00006… FBI_… TRUE    
    4 Rulemaking    2021-05-02T01:06:49Z NA                 FBI      "National Instant C… 0b00006… FBI-… TRUE    
    5 Rulemaking    2021-05-02T01:06:49Z NA                 FBI      "FBI Criminal Justi… 0b00006… FBI-… TRUE    
    6 Nonrulemaking 2021-05-02T01:06:49Z NA                 FBI      "FBI Records Manage… 0b00006… FBI-… TRUE 

``` r
FBI_dockets$id
```

    > FBI_dockets$id
    [1] "FBI-2024-0001"  "FBI-2023-0001"  "FBI_FRDOC_0001" "FBI-2013-0001"  "FBI-2008-0001"  "FBI-2008-0003"  "FBI-2016-0001"  "FBI-2008-0002" "FBI-2011-0001" 

#### Get documents from a docket folder

-   `get_documents("[docketId]")` retrieves documents for a docket

``` r
FBI_docket_2024 <- get_documents(docketId = "FBI-2024-0001", api_keys = api_keys)

head(FBI_docket_2024)
```

    > head(FBI_docket_2024)
    # A tibble: 1 × 16
      documentType lastModifiedDate    highlightedContent frDocNum withdrawn agencyId commentEndDate title postedDate
      <chr>        <chr>               <chr>              <chr>    <lgl>     <chr>    <chr>          <chr> <chr>     
    1 Rule         2024-07-26T01:01:2… ""                 2024-14… FALSE     FBI      2024-08-01T03… Bipa… 2024-07-0…
    # ℹ 7 more variables: docketId <chr>, subtype <lgl>, commentStartDate <chr>, openForComment <lgl>,
    #   objectId <chr>, id <chr>, lastpage <lgl>

``` r
FBI_docket_2024$objectId
```

    > FBI_docket_2024$objectId
    [1] "09000064865d514a"

#### Get metadata for comments on a document or docket

`get_commentsOnId("[objectId]")` retrieves comments on a specific
document (e.g., a specific proposed rule)

``` r
commentsOn_FBI_docket_2024 <- get_commentsOnId(commentOnId = "09000064865d514a", api_keys = api_keys)

# There is only one comment on this document 
head(commentsOn_FBI_docket_2024)
```

    # A tibble: 1 × 11
      documentType    lastModifiedDate highlightedContent withdrawn agencyId title objectId postedDate id    lastpage
      <chr>           <chr>            <chr>              <lgl>     <chr>    <chr> <chr>    <chr>      <chr> <lgl>   
    1 Public Submiss… 2024-07-26T13:2… ""                 FALSE     FBI      Comm… 0900006… 2024-07-2… FBI-… TRUE    
    # ℹ 1 more variable: commentOnId <chr>

``` r
commentsOn_FBI_docket_2024$id
```

    > commentsOn_FBI_docket_2024$id
    [1] "FBI-2024-0001-0002"

#### Get detailed metadata about a comment

`get_comment_details_content("[id]")` retrieves comments on a specific
document (e.g., a specific proposed rule)

``` r
comment <- get_comment_details(id = "FBI-2024-0001-0002", api_keys = api_keys)

# We retrieve 19 attributes for this single comment 

colnames(comment)
```

    > colnames(comment)
     [1] "commentOn"           "commentOnDocumentId" "duplicateComments"   "agencyId"            "comment"             "docketId"           
     [7] "documentType"        "objectId"            "modifyDate"          "organization"        "pageCount"           "postedDate"         
    [13] "receiveDate"         "title"               "trackingNbr"         "withdrawn"           "openForComment"      "id"                 
    [19] "attachments"  

``` r
comment$comment
```

    > comment$comment
    [1] "See attached file(s)"

``` r
# We can use the following attachments attribute to download the file(s)
comment$attachments
```

    > comment$attachments
    [[1]]
    [[1]][[1]]
                                                                    fileUrl format   size
    1 https://downloads.regulations.gov/FBI-2024-0001-0002/attachment_1.pdf    pdf 101230

## Search

The package also contains functions to use the API’s search function to
search the text of documents or comments:

-   `get_searchTerm(searchTerm = "[searchTerm]", documents = c("documents", "comments"), agency_acronym = c("all", "[agency_acronym]"), docket_id = c("all", "[docket_id]"), document_id = c("all", "[document_id]")  )`

## Download

Finally, using URLs returned from `get_documents()` and
`get_comment_details()`, we can download files (e.g., pdfs)

-   `download_regulationsdotgov("[url]")` saves local copies of desired
    files in a standard file structure mirroring that above in a “files”
    folder:
    “files/agency_acronym/docket_id/document_id/document_name.extension”
    (e.g., “files/ACF/ACF-2009-0005/ACF-2009-0005-0018_1.doc” is a
    public comment on ACF Notice ACF-2009-0005-0002. This notice is
    located at “files/ACF/ACF-2009-0005/ACF-2009-0005-0002.pdf”)

To specify your own file structure, simply use the base download
function

-   `download.file(url = "[url]", destfile = "[path]")`

## Important notes

-   To use `regulationsdotgov,` you will need an API key. These keys
    have limits. You can request a rate increase.

-   The functions are currently built with the theory that the user
    wants all results for a given agency/docket/document. While not
    highlighted in the documentation, a user can limit the search to
    results *before* a given date with a `lastModifiedDate` argument
    (API calls are currently hard-coded to be in descending order). In
    the future, we will add more options to restrict results to a given
    timeframe.
