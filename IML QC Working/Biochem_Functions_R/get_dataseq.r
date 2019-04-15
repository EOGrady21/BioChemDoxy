# get data sequence from datatype table from BioChem

get_dataseq <- function(datatype) {
  
  require(RODBC)
  
  # make cnnection to the osccruise database
  con = odbcConnect( dsn="PTRAN", uid=biochem.user, pwd=biochem.password, believeNRows=F)
  
  # get list of data type sequence form BIOCHEM.BCDATATYPES
  
  # construct query
  
  dtype= paste("'",as.character(datatype),"'",collapse=", ",sep="") # data type as strings in quotes
  
  query=paste0("select METHOD, DATA_TYPE_SEQ, DATA_RETRIEVAL_SEQ
                from BIOCHEM.BCDATATYPES
                where METHOD IN (", dtype, ");")



  # run query on the osc cruise database  
  res = sqlQuery(con, query )
  
  # convert all factors to characters
  res=data.frame(lapply(res, as.character), stringsAsFactors=FALSE)
  
  drs=res$DATA_RETRIEVAL_SEQ
  
  close(con)
  
  return(res)
  
  }