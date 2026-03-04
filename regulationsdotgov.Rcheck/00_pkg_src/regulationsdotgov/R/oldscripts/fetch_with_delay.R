

fetch_with_delay <- function(path, delay_seconds) {
  Sys.sleep(delay_seconds)
  GET(path)
}
