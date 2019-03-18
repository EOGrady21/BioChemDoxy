# plots cruse track on the map using information from BCS metadata file
# it is using leaflet library

cruisetrack_bcs = function(df) {
  
  # check if leaflet is installed, if not then install
  if (!is.installed("leaflet")){
    install.packages("leaflet")
  }
  
  
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
  #m <- addTiles(m)
  m <- addTiles(m, urlTemplate='http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}')
  #m <- addCircleMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label, radius=4, color="blue")
  m <- addMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label)
  
  m <- addPolylines(m, lng = ~EVENT_MIN_LON, lat = ~EVENT_MIN_LAT)
  m
  
}

