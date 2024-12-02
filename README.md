# regulationsdotgov


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
# You need an API key, you can register for one at https://open.gsa.gov/api/regulationsgov/.

api_keys <- "123tHiSkEyIsFaKe"

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
FBI_docket_2013 <- get_documents(docketId = "FBI-2013-0001", api_keys = api_keys)

head(FBI_docket_2013)
```

    > head(FBI_docket_2013)
    # A tibble: 2 × 17
      documentType  lastModifiedDate  highlightedContent frDocNum withdrawn agencyId allowLateComment commentEndDate title postedDate docketId subtype
      <chr>         <chr>             <chr>              <chr>    <lgl>     <chr>    <lgl>            <chr>          <chr> <chr>      <chr>    <lgl>  
    1 Proposed Rule 2013-03-30T02:01… ""                 2013-01… FALSE     FBI      FALSE            2013-03-30T03… Nati… 2013-01-2… FBI-201… NA     
    2 Notice        2013-03-22T20:22… ""                 NA       FALSE     FBI      FALSE            NA             Dock… 2013-03-2… FBI-201… NA     
    # ℹ 5 more variables: commentStartDate <chr>, openForComment <lgl>, objectId <chr>, id <chr>, lastpage <lgl>

``` r
# Although the docket contains two documents, only the 'Proposed Rule' had a comment period, so we'll use the objectId for that document to collect comments.
FBI_docket_2013$objectId[1]
```

    > FBI_docket_2013$objectId[1]
    [1] "09000064811daace"

#### Get metadata for all comments on a document

`get_commentsOnId("[objectId]")` retrieves comments on a specific
document (e.g., a specific proposed rule)

``` r
commentsOn_FBI_docket_2013 <- get_commentsOnId(commentOnId = "09000064811daace", api_keys = api_keys)

# There are 36 comments on this document, we can see the metadata for the first 6 below
head(commentsOn_FBI_docket_2013)
```

    > head(commentsOn_FBI_docket_2013)
    # A tibble: 6 × 11
      documentType      lastModifiedDate     highlightedContent withdrawn agencyId title                objectId postedDate id    lastpage commentOnId
      <chr>             <chr>                <chr>              <lgl>     <chr>    <chr>                <chr>    <chr>      <chr> <lgl>    <chr>      
    1 Public Submission 2013-04-01T17:16:07Z ""                 FALSE     FBI      Comment on FR Doc #… 0900006… 2013-04-0… FBI-… TRUE     0900006481…
    2 Public Submission 2013-04-01T17:15:49Z ""                 FALSE     FBI      Comment on FR Doc #… 0900006… 2013-04-0… FBI-… TRUE     0900006481…
    3 Public Submission 2013-04-01T17:15:25Z ""                 FALSE     FBI      Comment on FR Doc #… 0900006… 2013-04-0… FBI-… TRUE     0900006481…
    4 Public Submission 2013-04-01T17:15:07Z ""                 FALSE     FBI      Comment on FR Doc #… 0900006… 2013-04-0… FBI-… TRUE     0900006481…
    5 Public Submission 2013-04-01T17:14:34Z ""                 FALSE     FBI      Comment on FR Doc #… 0900006… 2013-04-0… FBI-… TRUE     0900006481…
    6 Public Submission 2013-04-01T17:14:13Z ""                 FALSE     FBI      Comment on FR Doc #… 0900006… 2013-04-0… FBI-… TRUE     0900006481…

``` r
# Now we'll store the id for each comment on the document 
comments_to_collect <- commentsOn_FBI_docket_2013$id

head(comments_to_collect)
```

    > head(comments_to_collect)
    [1] "FBI-2013-0001-0038" "FBI-2013-0001-0037" "FBI-2013-0001-0036" "FBI-2013-0001-0035" "FBI-2013-0001-0034" "FBI-2013-0001-0033"

#### Get detailed metadata about individual comments

`get_comment_details_content("[id]")` retrieves comments on a specific
document (e.g., a specific proposed rule)

``` r
comments <- get_comment_details(id = comments_to_collect, api_keys = api_keys)

# We retrieve 21 attributes for these 36 comments 

colnames(comments)
```

    > colnames(comment)
     [1] "commentOn"           "commentOnDocumentId" "duplicateComments"   "agencyId"            "comment"             "docketId"           
     [7] "documentType"        "objectId"            "modifyDate"          "organization"        "pageCount"           "postedDate"         
    [13] "receiveDate"         "title"               "trackingNbr"         "withdrawn"           "openForComment"      "id"                 
    [19] "attachments"  

``` r
# Let's take a look a closer look at one of the comments. 
comments$comment[23]
```

    > comments$comment[23]
    [1] "Docket No. FBI 152, Proposal 1 should be approved to stem gang violence and prevent youth suicide on Indian reservations."

``` r
# We can use the following attachments attribute to download any file(s) that may accompany the comment. 
comments$attachments[23]
```

    > comments$attachments[23]
    [[1]]
    [[1]][[1]]
                                                                     fileUrl format   size
    1 https://downloads.regulations.gov/FBI-2013-0001-0015/attachment_1.docx   docx 153789
    2  https://downloads.regulations.gov/FBI-2013-0001-0015/attachment_1.pdf    pdf  74106

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
