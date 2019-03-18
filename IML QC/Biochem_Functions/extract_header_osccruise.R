# Extract metadata from OSCCRUISE database to fill in Microcat header
# information; trial version
# Created by: Gordana Lazin, May 2015
# Query has to be modified to extract desired fields
# The tables in OSCCRUISE database are not ready

osccruise <- function (mission) {

require(RODBC)

# make cnnection to the osccruise database
con = odbcConnect( dsn="PTRAN", uid="lazing", pwd="Fdg8833p", believeNRows=F)

# construct query
query=paste0("select meds_cruise_number as mission_descriptor
            , cruise_number as mission_name 
            , platform as mission_platform
            , start_date as mission_sdate
            , end_date as mission_edate
            , organizations as mission_institute
            , first_name || ' ' || last_name as mission_leader
            , location as mission_geographic_region
            , comments
            from osccruise.cruise
            where meds_cruise_number='", mission, "';")
  
# run query on the osc cruise database  
res = sqlQuery(con, query )

# convert all factors to characters
res=data.frame(lapply(res, as.character), stringsAsFactors=FALSE)

return(res)
}