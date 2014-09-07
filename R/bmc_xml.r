#' Download full text xml of a BMC paper.
#' 
#' @import httr XML assertthat
#' @importFrom stringr str_extract_all
#' @export
#' @param obj (optional) An object of class bmc, from a call to \code{bmc_search}
#' @param uris (optional) A uri to a xml file of a BMC paper
#' @param dir (optional) A directory to save to. The file extension is forced to 
#' .xml, and the file name will be 
#' @param raw (logical) If TRUE, returns raw text, but if FALSE, parsed XML. Default: FALSE
#' @param ... Futher args passed on to httr::GET for debugging curl calls.
#' @examples \dontrun{
#' uri = 'http://www.biomedcentral.com/content/download/xml/1471-2393-14-71.xml'
#' uri = 'http://www.springerplus.com/content/download/xml/2193-1801-3-7.xml'
#' uri = 'http://www.microbiomejournal.com/content/download/xml/2049-2618-2-7.xml'
#' bmc_xml(uris=uri)
#' bmc_xml(uri, dir='~/')
#' bmc_xml(uri, verbose())
#' 
#' # from using bmc_search
#' out <- bmc_search(terms = 'science', limit=5)
#' dat <- bmc_xml(out)
#' length(dat)
#' library(plyr)
#' dat <- compact(dat)
#' length(dat)
#' dat
#' library(XML)
#' xpathApply(dat[[1]], "//abs", xmlValue)
#' saveXML(dat[[1]], file = 'myxml.xml')
#' }

bmc_xml <- function(obj=NULL, uris=NULL, dir=NULL, raw=FALSE)
{
  if(!is.null(obj)){ 
    assert_that(is(obj, "bmc"))
    toget <- obj@ids
    # construct download url
    uris <- vapply(toget, function(w){
      url <- gsub('[0-9].+', '', w['url'])
      paste0(url, 'download/xml/', w['arxId'], '.xml')
    }, "")
  }
  
  getxml <- function(x){
    res <- GET(x)
    if(!res$status_code == 200){
      message(sprintf('%s not found, or xml not available', x))
    } else
    {
      tt <- content(res, as = "text")
      
      if(raw){ tt } else {
        xml <- tryCatch(xmlParse(tt), error = function(e) e, silent=TRUE)
        if(is(xml, 'simpleError')){
          message(sprintf('%s is not valid xml', x))
        } else {
          if(!is.null(dir)){
            filedir <- paste0(dir, str_extract_all(x, "[0-9].+")[[1]], collapse = '')
            saveXML(xml, file = filedir)
          } else { return( xml ) }
        }
      }
      
    }
  }
  
  lapply(uris, getxml)
}
