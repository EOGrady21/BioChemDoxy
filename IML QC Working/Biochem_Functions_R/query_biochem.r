# query BioChem. The input is query string.

 query_biochem <- function(query) {

   require(RODBC)

# make cnnection to the osccruise database
con = odbcConnect( dsn="PTRAN", uid=biochem.user, pwd=biochem.password, believeNRows=F)

  
# run query on the osc cruise database  
res = sqlQuery(con, query )

# convert all factors to characters
res=data.frame(lapply(res, as.character), stringsAsFactors=FALSE)

close(con)

return(res)

}