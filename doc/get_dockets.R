## ----warning=FALSE, message=FALSE---------------------------------------------
# you need an API key
source("~/api-key.R")

library(regulationsdotgov)

devtools::load_all()


## ----warning=FALSE------------------------------------------------------------

# get FBI dockets
FBI_dockets <- get_dockets("FBI")

head(FBI_dockets)[[1]]$data # FIXME we should not need the [[1]]$data when this no longer returns a list

