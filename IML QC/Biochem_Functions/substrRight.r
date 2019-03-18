# extract last n characters from a string

substrRight <- function(x, n){
  y=substr(x, nchar(x)-n+1, nchar(x))
  return(y)
}