devtools::load_all()
load("../keys.rda")


#TESTING
if(F){


  searchTerm =  c("national congress of american indians", "cherokee nation")
  searchTerm = c("climate justice", "environmental justice")
  searchTerm = c("racial", "latino")
  searchTerm = c("racial")

  documents = c("documents", "comments")


  search_to_csv <- function(searchTerm, documents){
    path <- here::here("data", "metadata", searchTerm)

    dir.create(path)

    d <- get_searchTerm(searchTerm, documents, api_keys = keys)

    write_csv(d, file = here::here(path, paste0(searchTerm, "_", documents, ".csv")))
  }

  walk2(searchTerm, documents, .f = search_to_csv)


  search_to_rda <- function(searchTerm, documents){
    path <- here::here("data", "metadata", searchTerm)

    dir.create(path)

    d <- get_searchTerm(searchTerm, documents, api_keys = keys)

    save(d, file = here::here(path, paste0(searchTerm, "_", documents, ".rda")))
  }

  for(documents in documents){
    walk(searchTerm, documents, .f = search_to_rda)
  }



}
