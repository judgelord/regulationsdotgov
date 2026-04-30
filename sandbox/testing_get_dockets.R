# Testing get_dockets 

if(F){
  agency <- "PHMSA"

  n <- get_dockets(agency, api_keys = keys, lastModifiedDate = "2015-01-01%2000:00:00", lastModifiedDate_mod = "le")
  
  n <- get_dockets(agency, api_keys = keys, lastModifiedDate_mod = "ge")
  
  get_dockets_batch(agency, api_keys = keys, lastModifiedDate = "2015-01-0100:00:00", lastModifiedDate_mod = "ge")
  
  make_path_dockets(agency, api_key = api_key, lastModifiedDate = "2015-01-01%2000:00:00", lastModifiedDate_mod = "ge", page = 1)

}



