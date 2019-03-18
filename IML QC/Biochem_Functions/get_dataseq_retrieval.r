# get data sequence from datatype table from BioChem

get_dataseq_retrieval <- function(datatype) {
  
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
  
  # get precision, minimum and max from BCDATARETRIEVALS table
  
  query2=paste0("select DATA_RETRIEVAL_SEQ, PLACES_BEFORE, PLACES_AFTER, MINIMUM_VALUE, MAXIMUM_VALUE
from BIOCHEM.BCDATARETRIEVALS where DATA_RETRIEVAL_SEQ ='", drs, "';")
  
  retSeq=sqlQuery(con, query2 )
  
  # merge all information and make dataframe with following columns: 
  # DATA_RETRIEVAL_SEQ, METHOD, DATA_TYPE_SEQ, PLACES_BEFORE, PLACES_AFTER, MINIMUM_VALUE, MAXIMUM_VALUE
  
  outdf=merge(res,retSeq,by="DATA_RETRIEVAL_SEQ")
  
  
  close(con)
  
  return(outdf)
  
  }