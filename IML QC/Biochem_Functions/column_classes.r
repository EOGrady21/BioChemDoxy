# gives column class for the dataframe

column_classes <- function(df) {
  
  clases=lapply(df, function(x){class(x)})
  return(clases)
}