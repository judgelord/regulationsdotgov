# should give this a new name at some point

make_dataframe <- function(metadata){
  data <- metadata$data
  meta <- metadata$meta

  data_frame <- data$attributes %>%
    as_tibble() %>%
    mutate(id = data$id,
           # type = data$type, # we already ahve documentType = Public Submission, so this adds no new info
           # links = data$links$self, # can easily reconstruct from id
           lastpage = meta$lastPage)
  return(data_frame)
}
