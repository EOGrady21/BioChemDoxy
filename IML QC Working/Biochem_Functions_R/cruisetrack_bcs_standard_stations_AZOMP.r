# plots cruse track on the map using information from BCS metadata file
# it is using leaflet library

cruisetrack_bcs_standard_stations_AZOMP = function(df) {
  
  # check if leaflet is installed, if not then install
  if (!is.installed("leaflet")){
    install.packages("leaflet")
  }
  


  # load the file with standard station locations and names
  fn="AZMP_Stations_Definition.csv" # file should be in the working directory
  fp=file.path(getwd(),fn) # file name with the path
  
  # read standard stations (ss)
  ss=read.csv(fp, stringsAsFactors=FALSE)
  
  # bridge log columns
  blc=c("EVENT_COLLECTOR_STN_NAME","EVENT_SDATE","EVENT_MIN_LAT","EVENT_MIN_LON","EVENT_STIME")
  
  # select unique combinations of station, date, lat and lon
  j= which(!duplicated(df[,blc]))
  
  # contains unique combinations of station, date, and position
  pl=df[j,blc] 
  
  # define label for popups
  pl$label=paste0(pl$EVENT_COLLECTOR_STN_NAME, ", ",pl$EVENT_SDATE,", ",pl$EVENT_STIME)
  
  # find indices for stations without names
  noname=which(pl$EVENT_COLLECTOR_STN_NAME=="NaN")
  
  # plot cruise track in leaflet
  library(leaflet)
  
  m <- leaflet(data=pl)
  #m <- addTiles(m)
  m <- addTiles(m, urlTemplate='http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}')
  #m <- addCircleMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label, radius=3, color="blue")
  m <- addMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label)
  
  m <- addPolylines(m, lng = ~EVENT_MIN_LON, lat = ~EVENT_MIN_LAT)
  
  # add stations with no name
  if (length(noname)>1) {
    m <- addCircleMarkers(m, data=pl[noname,], lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label, radius=10, color = 'black')
    
  }
  
  # add standard stations
  m <- addCircleMarkers(m, data=ss, lng=~lon, lat=~lat, popup= ~short.name, radius=4, color="red")
  
  
  
 
  
  m
  
}

