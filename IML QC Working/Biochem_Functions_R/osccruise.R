# Extract cruise metadata from OSCCRUISE database based on cruise number (like HUD2012043)

# Created by: Gordana Lazin, May 2015

# Query can be modified to extract desired fields.




osccruise <- function (mission) {

require(RODBC)

# make cnnection to the osccruise database
con = odbcConnect( dsn="PTRAN", uid=biochem.user, pwd=biochem.password, believeNRows=F)

# construct query
query=paste0("select meds_cruise_number as mission_descriptor
            , cruise_number as mission_name 
            , platform as mission_platform
            , start_date as mission_sdate
            , end_date as mission_edate
            , leg 
            , organizations as mission_institute
            , first_name || ' ' || last_name as mission_leader
            , location as mission_geographic_region
            , comments
            from osccruise.cruise
            where cruise_number='", mission, "';")
  
# run query on the osc cruise database  
res = sqlQuery(con, query )

# convert all factors to characters
res=data.frame(lapply(res, as.character), stringsAsFactors=FALSE)

close(con)

return(res)
}