# plot AZOMP cruises on the map
# using information from BCS file that contains all misions
# Gordana Lazin, October 2017, BioChem Reboot roject

require(leaflet)
require(htmlwidgets)
source("cruisetrack_bcs_standard_stations_AZOMP.r")


bcs=read.csv("AZOMP_MISSIONS_BCS.csv", header=T, stringsAsFactors=F)

# make a subset for plotting
pd=bcs[,c("MISSION_DESCRIPTOR","EVENT_COLLECTOR_STN_NAME","EVENT_SDATE","EVENT_MIN_LAT","EVENT_MIN_LON","EVENT_STIME")]

pd$date=as.Date(pd$EVENT_SDATE,"%d-%b-%Y") # add date for ordering

#order by date and time
pd=pd[with(pd, order(date, EVENT_STIME)), ]

# take only one record per ststion
pd=unique(pd)


# plot all cruises in the loop

ud=as.character(unique(pd$MISSION_DESCRIPTOR)) # all mission descriptors

for (i in 1:length(ud)) {
    
  # #data for one cruise
  pdm=pd[which(pd$MISSION_DESCRIPTOR==ud[i]),]
  #   
  ct1=cruisetrack_bcs_standard_stations_AZOMP(pdm)
  
  ct1=addLegend(ct1, "topright", colors="dodgerblue", labels=paste(ud[i]), title="AZOMP Mission")
  # 
  # 
  saveWidget(ct1, file=paste0(ud[i],"_cruisetrack.html"))
  
}