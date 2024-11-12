devtools::load_all()
load("../keys.rda")


#TESTING
if(F){
  d <- get_searchTerm(searchTerm) # documents, the default

  d <- get_searchTerm(searchTerm, documents = "comments") # comments
  
  d <- get_searchTerm(searchTerm = "abolition", 
                 documents = "documents", 
                 api_keys = api_keys)



  # write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))

  searchTerm =  c("national congress of american indians", "cherokee nation")

  searchTerm = c("climate justice", "environmental justice")

  searchTerm = c("environmental justice")

  documents = c("documents", "comments")

  documents = c("comments")

  documents = c("documents")


  search_to_csv <- function(searchTerm, documents){
    d <- get_searchTerm(searchTerm, documents)

    write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))
  }

  walk2(searchTerm, documents, .f = search_to_csv)


  search_to_rda <- function(searchTerm, documents){
    d <- get_searchTerm(searchTerm, documents)

    save(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".rda")))
  }

  walk2(searchTerm, documents, .f = search_to_rda)
}
