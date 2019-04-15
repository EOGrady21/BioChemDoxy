# extract metadata from BioChem based on Sample ID numbers

biochem_metadata_sampleID <- function(sampleid) {
  
  require(RODBC)
  
  # make cnnection to the osccruise database
  con = odbcConnect( dsn="PTRAN", uid="lazing", pwd="Fdg8833p", believeNRows=F)
  

  # add single quotes an commas between sample ID's
  sid=paste("'",as.character(sampleid),"'",collapse=", ",sep="")
  
  
#   query=paste0("select distinct COLLECTOR_SAMPLE_ID, NAME, EVENT_START, COLLECTOR_STATION_NAME, EVENT_MIN_LAT, EVENT_MIN_LON, HEADER_START_DEPTH, METHOD
#                from BIOCHEM.DISCRETE_DATA
# where COLLECTOR_SAMPLE_ID IN (",sid,") ORDER BY COLLECTOR_SAMPLE_ID ;")
  
  query=paste0("select distinct COLLECTOR_SAMPLE_ID, NAME, METHOD, GEAR_MODEL, COLLECTOR
               from BIOCHEM.DISCRETE_DATA
where COLLECTOR_SAMPLE_ID IN (",sid,") ORDER BY COLLECTOR_SAMPLE_ID ;")
  
  
  # run query on the biochem database  
  res = sqlQuery(con, query )
  
  # convert all factors to characters
  res=data.frame(lapply(res, as.character), stringsAsFactors=FALSE)
  
  close(con)
  
  return(res)
  
}