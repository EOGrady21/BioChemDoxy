# stack wide data table using melt and look up BioChem data sequence for each datatype
# Gordana Lazin may 12, 2016

stack_bcdata <- function(df) {
  
  source("get_dataseq.r") # function taht extract data sequence from BioChem
  
  # stack data using melt function
  dfs=as.data.frame(melt(df,"id",na.rm=TRUE)) # stacked data frame
  
  # what are the datatypes
  datatypes=as.character(unique(dfs$variable))
  
  # extract data type sequences from biochem table
  bctypes=get_dataseq(datatypes)
  
  # datatypes that are not found in biochem
  metdif=setdiff(datatypes,bctypes$METHOD)
  
  if (length(metdif)>0) {
    ind=which(dfs$variable %in% metdif) # indices of columns
    cat(paste("Data types are not found in BioChem:",paste(metdif,collapse=", ")))
    cat("\n","\n")
    op=readline("Would you like to remove those datatypes from the dataset (y or n)?: ")
    if (op=="y") {
      dfs=dfs[-ind,]
      cat("-> Methods removed from the dataset.")
    }
    
    if (op=="n") {
      cat("-> Please edit original data column names so they match BioChem Method") 
      stop()
    }
    
  }
  
  # now add column for data sequence: merge stacked data with bctypes
  # mbs is merged data frame
  mdf=merge(dfs,bctypes,by.x="variable", by.y="METHOD")
  
  
  return(mdf)
    
}