# get data precision from BIOCHEM.BCDATARETRIEVALS table. 
# Input is DATA_RETRIEVAL_SEQ that can be a vector.
# Output is DATA_RETRIEVAL_SEQ, METHOD, DATA_TYPE_SEQ, PLACES_BEFORE, PLACES_AFTER, MINIMUM_VALUE, MAXIMUM_VALUE
# Gordana lazin, September 2, 2016


get_precision <- function(rSeq) {
  
  require(RODBC)
  
  # make cnnection to the osccruise database
  con = odbcConnect( dsn="PTRAN", uid=biochem.user, pwd=biochem.password, believeNRows=F)
  
  retr= paste("'",as.character(rSeq),"'",collapse=", ",sep="") # data type as strings in quotes
  
  # get precision, minimum and max from BCDATARETRIEVALS table
  
  query2=paste0("select DATA_RETRIEVAL_SEQ, PLACES_BEFORE, PLACES_AFTER, MINIMUM_VALUE, MAXIMUM_VALUE
from BIOCHEM.BCDATARETRIEVALS where DATA_RETRIEVAL_SEQ IN (", retr, ");")
  
  retSeq=sqlQuery(con, query2 )
  
  # merge all information and make dataframe with following columns: 
  # DATA_RETRIEVAL_SEQ, METHOD, DATA_TYPE_SEQ, PLACES_BEFORE, PLACES_AFTER, MINIMUM_VALUE, MAXIMUM_VALUE
  
  prec=retSeq$PLACES_AFTER
    
  close(con)
  
  return(retSeq)
  
}

