pkgname <- "regulationsdotgov"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "regulationsdotgov-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('regulationsdotgov')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("get_commentsOnId")
### * get_commentsOnId

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: get_commentsOnId
### Title: Get metadata for all comments on a document
### Aliases: get_commentsOnId

### ** Examples


# comment_metadata <- get_commentsOnId(commentOnId = "09000064865d514a", api_keys = "DEMO_KEY")

# head(comment_metadata)

# A tibble: 1 × 11
#   documentType      lastModifiedDate    highlightedContent withdrawn agencyId title objectId postedDate id   
#   <chr>             <chr>               <chr>              <lgl>     <chr>    <chr> <chr>    <chr>      <chr>
# 1 Public Submission 2024-07-26T13:29:3… ""                 FALSE     FBI      Comm… 0900006… 2024-07-2… FBI-…
# ℹ 2 more variables: lastpage <lgl>, commentOnId <chr>



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("get_commentsOnId", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("get_dockets")
### * get_dockets

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: get_dockets
### Title: Get dockets from an agency
### Aliases: get_dockets

### ** Examples


# FBI_dockets <- get_dockets(agency = "FBI", api_keys = "DEMO_KEY") 

# head(FBI_dockets)

# A tibble: 6 × 8
#   docketType    lastModifiedDate     highlightedContent agencyId title                objectId id    lastpage
#   <chr>         <chr>                <lgl>              <chr>    <chr>                <chr>    <chr> <lgl>   
# 1 Rulemaking    2024-08-26T13:14:32Z NA                 FBI      "Bipartisan Safer C… 0b00006… FBI-… TRUE    
# 2 Rulemaking    2024-08-26T13:13:45Z NA                 FBI      "Child Protection I… 0b00006… FBI-… TRUE    
# 3 Rulemaking    2023-08-25T08:08:48Z NA                 FBI      "Recently Posted FB… 0b00006… FBI_… TRUE    
# 4 Rulemaking    2021-05-02T01:06:49Z NA                 FBI      "National Instant C… 0b00006… FBI-… TRUE    
# 5 Rulemaking    2021-05-02T01:06:49Z NA                 FBI      "FBI Criminal Justi… 0b00006… FBI-… TRUE    
# 6 Nonrulemaking 2021-05-02T01:06:49Z NA                 FBI      "FBI Records Manage… 0b00006… FBI-… TRUE 


##{DELETE?}
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or standard data sets, see data().

## The function is currently defined as
#function (agency, lastModifiedDate = Sys.time()) 
#{
#    lastModifiedDate <- lastModifiedDate %>% ymd_hms() %>% with_tz(tzone = "America/New_York") %>% 
#        gsub(" ", "%20", .) %>% str_remove("\..*")
#    path <- make_path_dockets(agency, lastModifiedDate)
#    result <- purrr::map(path, GET)
#    status <<- tail(map(result, status_code), 1) %>% as.numeric()
#    url <- result[[20]][1]$url
#    if (status != 200) {
#        message(paste(format(Sys.time(), "%X"), "| Status", status, 
#            "| URL:", url))
#        Sys.sleep(6)
#    }
#    remaining <<- pluck(tail(map(result, headers), 1), 1, "x-ratelimit-remaining")
#    if (remaining < 2) {
#        message(paste(format(Sys.time(), "%X"), "- Hit rate limit, will continue after one minute"))
#        Sys.sleep(60)
#    }
#    docket_metadata <- purrr::map_if(result, ~status_code(.x) == 
#        200, ~fromJSON(rawToChar(.x$content)))
#    return(docket_metadata)
#  }
#


base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("get_dockets", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("get_documents")
### * get_documents

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: get_documents
### Title: Get documents from a docket folder
### Aliases: get_documents

### ** Examples


# FBI_docket_2024 <- get_documents(docketId = "FBI-2024-0001", api_keys = "DEMO_KEY")

# head(FBI_docket_2024)

# A tibble: 1 × 16
#   documentType lastModifiedDate     highlightedContent frDocNum   withdrawn agencyId # commentEndDate     title
#   <chr>        <chr>                <chr>              <chr>      <lgl>     <chr>    <chr>       #        <chr>
# 1 Rule         2024-07-26T01:01:24Z ""                 2024-14253 FALSE     FBI      2024-08# -01T03:59:… Bipa…
# ℹ 8 more variables: postedDate <chr>, docketId <chr>, subtype <lgl>, commentStartDate <chr>,
#   openForComment <lgl>, objectId <chr>, id <chr>, lastpage <lgl>



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("get_documents", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("get_searchTerm")
### * get_searchTerm

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: get_searchTerm
### Title: Search for a term
### Aliases: get_searchTerm

### ** Examples

##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (x) 
{
  }



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("get_searchTerm", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
