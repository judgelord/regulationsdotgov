\name{get_documents}
\alias{get_documents}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Get documents from a docket folder
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
get_documents("[docketId]") retrieves metadata for all documents belonging to a docket 
}
\usage{
get_documents(docketId, lastModifiedDate, api_keys)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{docketId}{
%%     ~~Describe \code{agency} here~~
ID of docket
}
  \item{lastModifiedDate}{
%%     ~~Describe \code{lastModifiedDate} here~~
Filter results by their last modified date. Default is set to \code{Sys.time()}. 

User-specified values must be formatted as \code{yyyy-MM-dd\%20HH:mm:ss}.

}
  \item{api_keys}{API key(s) from api.data.gov. 
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

# FBI_docket_2024 <- get_documents(docketId = "FBI-2024-0001", api_keys = "DEMO_KEY")

# head(FBI_docket_2024)

# A tibble: 1 × 16
#   documentType lastModifiedDate     highlightedContent frDocNum   withdrawn agencyId # commentEndDate     title
#   <chr>        <chr>                <chr>              <chr>      <lgl>     <chr>    <chr>       #        <chr>
# 1 Rule         2024-07-26T01:01:24Z ""                 2024-14253 FALSE     FBI      2024-08# -01T03:59:… Bipa…
# ℹ 8 more variables: postedDate <chr>, docketId <chr>, subtype <lgl>, commentStartDate <chr>,
#   openForComment <lgl>, objectId <chr>, id <chr>, lastpage <lgl>
}