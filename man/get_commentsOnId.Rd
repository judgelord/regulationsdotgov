\name{get_commentsOnId}
\alias{get_commentsOnId}
\title{
Get metadata for all comments on a document
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
get_commentsOnId("[objectId]") retrieves metadata for all comments on a document
}
\usage{
get_commentsOnId(objectId, lastModifiedDate, api_keys)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{objectId}{
objectId obtained from a document's metadata 
}
  \item{lastModifiedDate}{
%%     ~~Describe \code{lastModifiedDate} here~~
Filter results by their last modified date. Default is set to Sys.time(). 

User-specified values must be formatted as yyyy-MM-dd HH:mm:ss.

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

> comment_metadata <- get_commentsOnId(commentOnId = "09000064865d514a", api_keys = "DEMO_KEY")

> head(comment_metadata)

# A tibble: 1 × 11
  documentType      lastModifiedDate    highlightedContent withdrawn agencyId title objectId postedDate id   
  <chr>             <chr>               <chr>              <lgl>     <chr>    <chr> <chr>    <chr>      <chr>
1 Public Submission 2024-07-26T13:29:3… ""                 FALSE     FBI      Comm… 0900006… 2024-07-2… FBI-…
# ℹ 2 more variables: lastpage <lgl>, commentOnId <chr>
}