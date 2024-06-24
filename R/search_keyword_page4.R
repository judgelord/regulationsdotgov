# This script builds a function that pulls all documents/comments that include a keyword
#
source("../api-key.R")


library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)


# defaults
url  <- "https://api.regulations.gov"
rpp <- 250 # results per page
sortby <- "-postedDate" # decending posted date
page <- 1:20
lastModifiedDate = Sys.time() %>% str_replace_all("[A-Z]", " ") %>%  str_squish()
agency <- "BIA"
keyword = "national congress of american indians"
documenttype = "Public Submission"

search_keyword_page4 <- function(page = 1,
                                 documenttype = "Rule", # default
                                 keyword,
                                 lastModifiedDate = Sys.time() ){


  lastModifiedDate %<>% str_replace_all("[A-Z]", " ") %>%  str_squish()

  # format (replace space with unicode)
  search <- #keyword %>%
    str_c("%22", keyword, "%22") %>%
    str_replace_all(" ", "%2B")


  endpoint = ifelse(documenttype == "Public Submission", "comments", "documents")

  documentType = ifelse(documenttype == "Public Submission", "", str_c("&filter[documentType]=", documenttype)) #"&filter[documentType]=documents")

  path <- paste0("/v4/", endpoint,
                 "?page[number]=", page,
                 "&page[size]=250",
                 "&sort=-lastModifiedDate,documentId",
                 "&filter[searchTerm]=", search,
                 "&api_key=", api_key)

  # inspect path
  str_c("https://api.regulations.gov", path)

  raw.result <- GET(url = "https://api.regulations.gov", path = path)

  content <- fromJSON(rawToChar(raw.result$content))

  d <- content$data$attributes %>%  as_tibble()  %>%
    mutate(id = content$data$id,
           type = content$data$type,
           links = content$data$links$self,
           lastpage = content$meta$lastPage)

  #TODO loop this over batches of 5k documents
  # if(content$meta$lastPage){
  #   lastModifiedDate <-- content$data$attributes$lastModifiedDate %>% tail(1)
  #   #lastModifiedDate <-- Sys.time() %>% str_remove(" [A-Z]")
  # }

  return(d)
}



#NOTRUN
if(FALSE){
  d <- search_keyword_page4(keyword = "national congress of american indians",
                            documenttype = "Public Submission",
                            lastModifiedDate =  Sys.time()) #NOT SYS DATE!

  d$lastModifiedDate
  d$highlightedContent


  keywords <- c("national congress of american indians", "cherokee nation")

  d <- map(.x = keywords, search_keyword_page4(.x))
}


