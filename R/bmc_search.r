#' Search for gene sequences available for a species from NCBI.
#' 
#' @import httr methods
#' @importFrom plyr compact
#' @export
#' @param terms Search terms.
#' @param limit Number of records to return. Max 25. Default 10.
#' @param page Page number. Only applies if more than 25 results.
#' @param ... Further args passed on to httr::GET
#' @param x Object of class bmc from \code{bmc_search}
#' @return A list.
#' @examples \dontrun{
#' bmc_search(terms = 'ecology')
#' bmc_search(terms = 'fire', limit=3)
#' bmc_search(terms = 'fire', limit=2, page=1)
#' bmc_search(terms = 'fire', limit=2, page=2)
#' 
#' out <- bmc_search(terms = 'fire', limit=5)
#' out
#' 
#' # Search, then get full text
#' out <- bmc_search(terms = 'ecology')
#' out@@urls # you could use these to go to the website
#' out@@ids # used to construct download urls in bmc_xml
#' browseURL(out@@urls[1])
#' 
#' # curl debugging help
#' bmc_search(terms = 'ecology', verbose())
#' }

bmc_search <- function(terms, limit=10, page=1, ...)
{
  url = 'http://www.biomedcentral.com/search/results'
  args <- compact(list(terms = terms, itemsPerPage = limit, page = page, format = 'json'))
  out <- GET(url, query = args, ...)
  stop_for_status(out)
  tt <- content(out)
  urls <- vapply(tt$entries, function(z) z[['articleFullUrl']], "character")
  ids <- lapply(tt$entries, function(z) list(arxId=z[['arxId']], url=z[['articleFullUrl']]))
  new("bmc", urls=urls, ids=ids, results = tt)
}

setClass("bmc", slots=list(urls="character", ids="list", results="list"))

#' @method print bmc
#' @export
#' @rdname bmc_search
print.bmc <- function(x, ...)
{
  res <- x@results$entries
  print(res)
}

setMethod("show", "bmc", function(object) { print.bmc(object) })