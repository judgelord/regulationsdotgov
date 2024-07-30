\name{get_dockets}
\alias{get_dockets}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A Capitalized Title (ideally limited to 65 characters)
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
get_dockets(agency, lastModifiedDate = Sys.time())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{agency}{
%%     ~~Describe \code{agency} here~~
}
  \item{lastModifiedDate}{
%%     ~~Describe \code{lastModifiedDate} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or standard data sets, see data().

## The function is currently defined as
function (agency, lastModifiedDate = Sys.time()) 
{
    lastModifiedDate <- lastModifiedDate \%>\% ymd_hms() \%>\% with_tz(tzone = "America/New_York") \%>\% 
        gsub(" ", "\%20", .) \%>\% str_remove("\\..*")
    path <- make_path_dockets(agency, lastModifiedDate)
    result <- purrr::map(path, GET)
    status <<- tail(map(result, status_code), 1) \%>\% as.numeric()
    url <- result[[20]][1]$url
    if (status != 200) {
        message(paste(format(Sys.time(), "\%X"), "| Status", status, 
            "| URL:", url))
        Sys.sleep(6)
    }
    remaining <<- pluck(tail(map(result, headers), 1), 1, "x-ratelimit-remaining")
    if (remaining < 2) {
        message(paste(format(Sys.time(), "\%X"), "- Hit rate limit, will continue after one minute"))
        Sys.sleep(60)
    }
    docket_metadata <- purrr::map_if(result, ~status_code(.x) == 
        200, ~fromJSON(rawToChar(.x$content)))
    return(docket_metadata)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
