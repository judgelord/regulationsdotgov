\name{save_dockets}
\alias{save_dockets}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Save docket metadata in directory. 
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
save_dockets("[agency_acronym]") creates a data directory for collecting agency docket metadata within a folder structure. 
}
\usage{
save_dockets <- function(agency)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{agency}{
%%     ~~Describe \code{agency} here~~
Agency acronym(s) (see official acronyms on regulations.gov)
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
This function uses the get_dockets function internally, so you will need to have an 'api_keys' stored in your environment in order for it to function properly. 
}
\value{
Stores data as a .rmd file. 
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

agencies <- c("NLRB", "OMB", "TSA")

save_dockets(agencies)

}
