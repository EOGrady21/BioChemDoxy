# plot cruise track and stations

wd="C:/Gordana/Biochem_reload/working"
setwd(wd)



df=read.csv("18HU12042_BCS_test.csv")

cruisetrack_bcs(df)



cruisetrack_bcs = function(df) {

# bridge log columns
blc=c("EVENT_COLLECTOR_STN_NAME","EVENT_SDATE","EVENT_MIN_LAT","EVENT_MIN_LON")

# select unique combinations of station, date, lat and lon
j= which(!duplicated(df[,blc]))

# contains unique combinations of station, date, and position
pl=df[j,blc] 

# define label for popups
pl$label=paste0(pl$EVENT_COLLECTOR_STN_NAME,", ",pl$EVENT_SDATE)

# plot cruise track in leaflet
library(leaflet)

m <- leaflet(data=pl)
m <- addTiles(m)
m <- addMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label)
m <- addPolylines(m, lng = ~EVENT_MIN_LON, lat = ~EVENT_MIN_LAT)
m
}