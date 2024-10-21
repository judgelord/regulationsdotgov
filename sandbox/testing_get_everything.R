load("../keys.rda")
keys <- rev(keys)
devtools::load_all()
library(tidyverse)
library(httr)
library(jsonlite)
library(magrittr)

#agency <- c("BIA", "IHS")

agency <- c('RITA','FRA','FTA','MARAD','NHTSA','PHMSA','DOD',
            'DOT','EPA',
'FHWA','FMCSA','FAA','NRC','NOAA','USCG','AMS','FWS','BLM','COE',
'FEMA','NRCS','RBS','USDA','FDA','HUD','CEQ','TVA','FSIS','DOE',
'LSC','TREAS','RUS','GSA','FSA','RHS','BSEE','CCC','BIA','OSM','BOEM',
'EERE','NCPC','FS','ACF','PHS','CMS','HHSIG','HHS') |> rev()

agency <- c('ACF', #'ACL',
            'AID', 'AMS', 'BIA', 'BLM', 'BOEM', 'BSEE', 'CCC', 'CEQ', 'CMS', 'COE', 'CPSC', 'DOC', 'DOD',
'DOE', 'DOJ', 'DOS', 'DOT', 'EBSA', 'EERE', 'EPA', 'FAA', 'FAR', 'FDA', 'FEMA', 'FHWA', 'FMC', 'FMCSA', 'FRA', 'FS',
'FSA', 'FSIS', 'FTA', 'FWS', 'GSA', 'HHS', 'HHSIG', 'HUD', 'IRS', 'MARAD', 'NASA', 'NHTSA', 'NOAA', 'NRC', 'NRCS',
'NTSB', 'OCC', 'OSM', 'PHMSA', 'RBS', 'RHS', 'RITA', 'RUS', 'TREAS',
'USA', 'USCG', 'USDA', 'SRBC', 'FERC') |> rev()

agency <- c("PHS",   "NCPC",  "OSM",   "RHS",   "RUS",   "TREAS", "LSC",
            "TVA"  )

agency <- c("USPC")

agency <- "HHS"

# create directories for each agency
walk(here::here("data", agency), dir.create)


# SAVE IN SEPERATE FILES IN DOCKET FOLDERS
save_dockets <- function(agency){
  message (agency)
  dockets <- map_dfr(agency, get_dockets, api_keys = keys)
  message(paste("|", agency, "| n =", nrow(dockets), "|"))
  # agency <- "NOAA"
  # dockets <- metadata
  save(dockets, file = here::here("data",
                                    agency,
                                    paste0(agency, "_dockets.rda")
  )
  )
}


#FIXME alternatively, specify a date of last run and merge in with exisiting metadata file
downloaded <- list.files(pattern = "_dockets.rda", recursive = T) |>
  str_remove_all(".*/|_dockets.rda")

agency <- agency[!(agency %in% downloaded)]
agency

# To investigate: EPA-HQ-OW-2009-0819

walk(agency, possibly(save_dockets, otherwise = print("nope")))

# all agency folders
# agency <- list.dirs("data", recursive = F) |> str_remove("data/")

# create directories for each docket
for (agency in agency){

  message(agency)

  load(here::here("data", agency, paste0(agency, "_dockets.rda")))

  walk(here::here("data", agency, dockets$id), possibly(dir.create, otherwise = print("nope"))) #FIXME Currently this doesnt nest the data for multiple agencies
}




#### Get documents from each docket


# SAVE IN SEPERATE FILES IN DOCKET FOLDERS
save_documents <- function(docket, agency){
  message (paste(Sys.time(), agency, docket))
  documents <- map_dfr(docket, get_documents)
  message(paste("|", docket, "| n =", nrow(documents), "|"))
  save(documents, file = here::here("data",
                             agency, #str_extract("[A-Z]"), docket),
                             # should we require an agency argument here, or is there a reliable way to split agencies and dockets, e.g., by looking for years -19[0-9][0-9]- or -20[0-9][0-9]-
                             docket,
                             paste0(docket, "_documents.rda")
                             )
  )
}


# loop over a vector of agencies
for(agency in agency){
  # load dockets
  load(here::here("data", agency, paste0(agency, "_dockets.rda")))

  # id doc metadata already downloaded
  #FIXME alternatively, specify a date of last run and merge in with exisiting metadata file
downloaded <- list.files(pattern = "_documents.rda", recursive = T) |>
  str_remove_all(".*/|_documents.rda")

# if dockets metadata is not empty & docket metadata was not already downloaded, save documents for each docket
if("id" %in% names(dockets)){

dockets %<>% filter(!(id %in% downloaded))

walk2(dockets$id, dockets$agencyId, possibly(save_documents, otherwise = print("nope")))
} else{
  message(paste(agency, "has no document metadata returned by regulations.gov"))
}
}





# Aggregate docket-leve documents metadata to agency level and save in agency folder
for(agency in agency){

  # document metadata in docket folders
  files <- list.files(pattern = paste0(
    agency, ".*_documents.rda"), recursive = T
  )

  # aggregated metadata for the whole agency
  done <- list.files(pattern = paste0(
    agency, "_documents.rda"), recursive = T
    )

  if(!length(files) == 0 & length(done) == 0){
    load(files[1])
    d <- documents

    for(file in files){
      load(file)

      temp <- documents

      d <<- suppressMessages(full_join(d, temp))
    }

    documents <- d

    save(documents, file = here::here("data", agency, paste0(agency, "_documents.rda")))
  } else
    message(paste("Missing", agency))
}

###################
# Aggregate all agency-level document metadata and save in data folder
  files <- list.files(pattern = "^[A-Z]*_documents.rda", recursive = T)

length(files) == length(agency)

done <- files |> str_remove_all(".*/|-.*")

  load(files[1])
  d <- documents

  for(file in files){
    load(file)

    temp <- documents

    d <<- full_join(d, temp)
  }

  documents <- d

  agency[!agency %in% d$agencyId]

  save(documents, file = here::here("data", "all_documents.rda"))


d %>%
  #full_join(documents) %>%
  group_by(documentType,docketId) %>%
  slice_max(n = 1, with_ties = F, order_by = postedDate) %>%
  ungroup() %>%
  mutate(year = str_sub(postedDate,1,4) %>% as.numeric()) %>%
  filter(year > 1992,
         documentType %in% c("Rule", "Proposed Rule")) %>%
  ggplot() +
  aes(x = as.factor(year),
      fill = documentType) +
  geom_bar(position = "dodge")









#######################################################
#### Get metadata for comments on a document or docket

# get_comments_on_docket("[docket_id]") # retrieves all comments for a docket (e.g., including an Advanced Notice of Proposed Rulemaking and all draft proposed rules)

save_comments <- function(docket){
  #comments <- map_dfr(docket, get_comments_on_docket)

  # for testing
  # docket <- "EPA-HQ-OAR-2021-0317"
  docket <- "FBI-2024-0001"
  documents <- get_documents(docket, api_keys = keys)

  # documents |> count(documentType)

  documents |> filter(documentType == "Proposed Rule") |> select(commentStartDate, commentEndDate, withdrawn, subtype, objectId)

  # subset to proposed rules
  d <- documents |>
    filter(documentType == "Proposed Rule") |>
    select(document_subtype = subtype,
           commentStartDate, commentEndDate, frDocNum,
           commentOnId = objectId,
           document_title = title) |>
    #FIXME not sure if a 0 comment document was the source of the error I got
    drop_na(commentStartDate)


  # get comments
  c <- map_dfr( d$commentOnId, get_commentsOnId, api_keys = keys)

  # join back in document metadata
  c %<>% left_join(d)

  comments <- c  #|> filter(is.na(subtype )) # NA subtype = normal PR?

  save(comments, file = here::here("data",
                             str_extract(docket, "[A-Z]+"), # agency
                             docket,
                            paste(docket, "comments.rda", sep = "_")
  )
  )
}

walk(dockets, save_comments)


# METHOD 2 - DOCUMENT LEVEL
get_commentsOnId("[document_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)

save_comments <- function(document){
  comments <- map_dfr(document, get_commentsOnId)
  save(comments, here::here("data",
                            str_extract(document, "[A-Z]+)"), # agency
                            paste("document", "comments.rda")
  )
  )
}

walk(documents$id, save_comments)

#### Get detailed metadata about a comment

get_comment_details("[comment_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)


save_comment_details <- function(comments){
  #comments <- map_dfr(docket, get_comments_on_docket)
  comment_details <- get_comment_details(comments$id, api_keys = keys)

  save(comment_details, file = here::here("data",
                            str_extract(docket, "[A-Z]+"), # agency
                            docket,
                            paste(docket, "comment_details.rda", sep = "_")
  )
  )
}

walk(dockets, save_comment_details)

# DOWNLOAD ATTACHMENTS

# extract attachments from details
attachments <- comment_details$attachments |>
  flatten() |>
  map(as.data.frame) |> #FIXME, can we do this in one line?
  map_dfr(~.x)

# inspect
ggplot(attachments) +
  aes(x = size, fill = format) +
  geom_bar()

ggplot(attachments |> slice_max(size, n = 100)) +
  aes(x = size, fill = format) +
  geom_bar()

#TODO? drop large pdf files?
# attachments %<>% filter(size < 100000000) # = < 100 MB ?

attachment_urls <- attachments |>
  pull(fileUrl) |>
  unique()


download_comments(attachment_urls )




# CONVERT TO TXT
files <- list.files("comments", recursive = T)
length(files)
head(files)
converted <- list.files("comment_text", recursive = T) |> str_replace("txt", "pdf")
head(converted)
# files not converted
not_converted <- files[!files %in% converted]
head(not_converted)

# pdfs not converted
pdfs <- not_converted[str_detect(not_converted, "pdf")]

walk(pdfs, possibly(pdf_to_txt, otherwise = print("nope")))
