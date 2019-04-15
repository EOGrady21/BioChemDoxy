# plot core lab sea stastions L3 line on map

df=read.csv("L3_stations_jj_iy.csv", stringsAsFactors=F)

# read standard AZMP stations (ss)
ss=read.csv("AZMP_Stations_Definition.csv", stringsAsFactors=FALSE)

# read all azomp stations for the period 1999-2012
us=read.csv("all_azomp_stations.csv", stringsAsFactors=F)

library(leaflet)

m <- leaflet(data=df)
#m <- addTiles(m)
m <- addTiles(m, urlTemplate='http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}')
#m <- addMarkers(m, lng=~lon_iy, lat=~lat_iy, popup= ~as.character(stn_iy))
#m <- addCircleMarkers(m, data=us, lng=~lon_odf, lat=~lat_odf, popup= ~station_name, radius=8, color="green")




# add markers for all the stations
m <- addMarkers(m, data=us, lng=~lon_odf, lat=~lat_odf, popup= ~paste0(us$station_name,", ",us$date_odf))


# add L3 standard stations (lab Sea)
m <- addCircleMarkers(m, lng=~lon_jj, lat=~lat_jj, popup= ~stn_jj, radius=3, color="red")

# add standard AZMP stations
m <- addCircleMarkers(m, data=ss, lng=~lon, lat=~lat, popup= ~short.name, radius=4, color="red")

# find indices for stations without names
noname=us[which(us$station_name=="NaN"),]

# # add stations with no name
# if (length(noname)>1) {
   m <- addCircleMarkers(m, data=noname, lng=~lon_odf, lat=~lat_odf, popup= ~paste0(noname$station_name,", ",noname$date_odf), radius=10, color = 'black')
#   
# }

   saveWidget(m, file="azomp_all_stations_1999_2012.html")
