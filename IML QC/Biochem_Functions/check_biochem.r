# extract discrete dat method from each cruise

 check_biochem <- function(mission) {

   require(RODBC)

# make cnnection to the osccruise database
con = odbcConnect( dsn="PTRAN", uid=biochem.user, pwd=biochem.password, believeNRows=F)



query=paste0("select distinct METHOD, DATA_TYPE_DESC 
             from BIOCHEM.DISCRETE_DATA 
             where NAME LIKE '", mission, "' ORDER BY METHOD;")

  
# run query on the osc cruise database  
res = sqlQuery(con, query )

# convert all factors to characters
res=data.frame(lapply(res, as.character), stringsAsFactors=FALSE)

close(con)

return(res$METHOD)

}