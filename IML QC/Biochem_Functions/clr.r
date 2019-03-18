# clear function created so I don't have to type a lot every time I want to clear workspace
  
  clr <- function() {
    ENV <- globalenv()
    ll <- ls(envir = ENV)
    ll <- ll[ll != "clr"]
    rm(list = ll, envir = ENV)
  }