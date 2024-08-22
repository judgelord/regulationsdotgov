devtools::load_all()

#agency <- c("BIA", "IHS")

agency <- c('RITA','FRA','FTA','MARAD','NHTSA','PHMSA','DOD','DOT',#'EPA',
'FHWA','FMCSA','FAA','NRC','NOAA','USCG','AMS','FWS','BLM','COE',
'FEMA','NRCS','RBS','USDA','FDA','HUD','CEQ','TVA','FSIS','DOE',
'LSC','TREAS','RUS','GSA','FSA','RHS','BSEE','CCC','BIA','OSM','BOEM',
'EERE','NCPC','FS','ACF','PHS','CMS','HHSIG','HHS')

agency <- c("USPC")

# create directories for each agency
walk(here::here("data", agency), dir.create)

dockets <- map_dfr(agency, get_dockets)# retrieves dockets for an agency (see official acronyms on regulations.gov)

save(dockets, file = here::here("data", agency,
                                paste0(agency, "_dockets.rda")))

load(here::here("data", agency, paste0(agency, "_dockets.rda")))

# create directories for each docket
for (i in length(agency)){
  walk(here::here("data", agency[i], dockets$id), dir.create) #FIXME Currently this doesnt nest the data for multiple agencies
}


# create directories for each docket [alternative...can probably delete]
docket_paths <- paste(dockets$agencyId, #FIXME Should the get_dockets re-name this "agency"
                      dockets$id, #FIXME Should the get_dockets re-name this "docket_id"
                      sep = "/")

walk(here::here("data", docket_paths), dir.create)

#### Get documents from each docket

# SAVE IN SEPERATE FILES IN DOCKET FOLDERS
save_documents <- function(docket, agency){
  message (docket)
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

downloaded <- list.files(pattern = "_documents.rda", recursive = T) |>
  str_remove_all(".*/|_documents.rda")

dockets %<>% filter(!(id %in% downloaded)) %>%
  filter(!(id %in% c("EPA-HQ-OAR-2002-0065")))

# To investigate: EPA-HQ-OW-2009-0819

walk2(dockets$id, dockets$agencyId, possibly(save_documents, otherwise = print("nope")))

# SAVE ONE LAGE FILE IN AGENCY FOLDER
documents <- map_dfr(dockets$id, get_documents) # retrieves documents for a docket

save(documents, file = here::here("data", agency,
                                  paste0(agency, "_documents.rda")))


#### Get metadata for comments on a document or docket

# get_comments_on_docket("[docket_id]") # retrieves all comments for a docket (e.g., including an Advanced Notice of Proposed Rulemaking and all draft proposed rules)

save_comments <- function(docket){
  comments <- map_dfr(docket, get_comments_on_docket)
  save(comments, here::here("data",
                             str_extract("[A-Z]+)", docket), # agency
                             docket,
                            "comments.rda"
  )
  )
}

walk(dockets, save_comments)


# METHOD 2 - DOCUMENT LEVEL
get_commentsOnId("[document_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)

save_comments <- function(document){
  comments <- map_dfr(document, get_commentsOnId)
  save(comments, here::here("data",
                            str_extract("[A-Z]+)", document), # agency
                            paste("document", "comments.rda")
  )
  )
}

walk(documents$id, save_comments)

#### Get detailed metadata about a comment

get_comment_details("[comment_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)


save_comment_details <- function(docket){
  comments <- map_dfr(docket, get_comments_on_docket)
  comment_details <- get_comment_details(comments$document_id)

  save(comment_details, here::here("data",
                            str_extract("[A-Z]+)", docket), # agency
                            docket,
                            "comment_details.rda"
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
