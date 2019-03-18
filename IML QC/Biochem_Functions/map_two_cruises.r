# plot two cruises on the map on top of each other

cruise1="HUD2003078"

cruise2="HUD2007001"


# filenames with paths
file1=file.path(getwd(),cruise1,paste0(cruise1,"_BCS.csv"))

file2=file.path(getwd(),cruise2,paste0(cruise2,"_BCS.csv"))

# read the files

h1=read.csv(file1,stringsAsFactors=FALSE)

h2=read.csv(file2,stringsAsFactors=FALSE)


# lines from cruisetrack function

# ==== FIRST CRUISE ====
df=h1

# bridge log columns
blc=c("EVENT_COLLECTOR_STN_NAME","EVENT_SDATE","EVENT_MIN_LAT","EVENT_MIN_LON")

# select unique combinations of station, date, lat and lon
j= which(!duplicated(df[,blc]))

# contains unique combinations of station, date, and position
pl=df[j,blc] 

# define label for popups
pl$label=paste0(pl$EVENT_COLLECTOR_STN_NAME,", ",pl$EVENT_SDATE)


# === SECOND CRUISE =====
# select unique combinations of station, date, lat and lon
j2= which(!duplicated(h2[,blc]))

# contains unique combinations of station, date, and position
pl2=h2[j2,blc] 

# define label for popups
pl2$label=paste0(pl2$EVENT_COLLECTOR_STN_NAME,", ",pl2$EVENT_SDATE)
# === SECOND CRUISE PARAMETERS DONE ===







# plot cruise track in leaflet
library(leaflet)

m <- leaflet(data=pl)
#m <- addTiles(m)
m <- addTiles(m, urlTemplate='http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}')
#m <- addCircleMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label, radius=4, color="blue")
m <- addMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label)

m <- addPolylines(m, lng = ~EVENT_MIN_LON, lat = ~EVENT_MIN_LAT)

# add standard stations
m <- addCircleMarkers(m, data=pl2, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label, radius=4, color="red")
m <- addPolylines(m, data=pl2, lng = ~EVENT_MIN_LON, lat = ~EVENT_MIN_LAT, color="red")
m
