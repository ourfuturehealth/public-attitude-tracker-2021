# function to detect if a variable class contains a value label from .sav file

is.labelled <- function(x){
  
  if ("haven_labelled" %in% class(x)){
    return(TRUE)
  } else {
    return(FALSE)
  }
  
}