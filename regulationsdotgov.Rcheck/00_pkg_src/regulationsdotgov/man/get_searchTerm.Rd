\name{get_searchTerm}
\alias{get_searchTerm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Search for a term 
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~\
get_searchTerm("[searchTerm]") returns documents, comments, or dockets filtered by specific term
}
\usage{
get_searchTerm(searchTerm, documents, lastModifiedDate, api_keys)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{searchTerm}{
%%     ~~Describe \code{x} here~~
Term to filter by. 
}
\item{documents}{
%%     ~~Describe \code{x} here~~ GONNA CHANGE THIS TO ENDPOINT
Object to return. Default is set to \code{documents}. 

Valid options are \code{documents}, \code{comments}, or \code{dockets}. 

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
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (x) 
{
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
