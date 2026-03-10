# Testing get_documents



doc <- get_documents(docketId = "DOT-OST-2005-23307", api_keys = api_keys)

doc <- get_documents(agencyId = "FBI", docketId = "FBI-2024-0002", api_keys = api_keys)


make_path_documents(docketId = "DOT-OST-2005-23307", api_key = api_keys[1], lastModifiedDate = Sys.time(), 
                    page = 1)

get_documents_batch(docketId = "DOT-OST-2005-23307", api_keys = api_keys, lastModifiedDate = Sys.time())
