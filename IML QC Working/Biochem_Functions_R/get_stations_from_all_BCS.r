# assemble all station locations using all AZMP cruises
# plot a map with all stations occupied 1999-2012 for AZMP and save as html

cruises=c("HUD99054",
          "HUD2000050",
          "HUD2001061",
          "HUD2002064",
          "HUD2003067",
          "HUD2003078",
          "HUD2004055",
          "HUD2005055",
          "HUD2006052",
          "HUD2007045",
          "HUD2008037",
          "HUD2009048",
          "HUD2010049",
          "HUD2011043",
          "HUD2012042",
          "HUD99003",
          "PAR2000002",
          "HUD2001009",
          "HUD2003005",
          "HUD2004009",
          "NED2005004",
          "HUD2006008",
          "HUD2007001",
          "HUD2008004",
          "HUD2009005",
          "HUD2010006",
          "HUD2011004")


# # reprocess all data first
# for (i in 1: length(cruises)) {
#   mission=cruises[i]
#   source("bcs_azmp1.r")
# }

# load BCS files for all cruises

alldata=read.csv(file.path(getwd(),cruises[1],paste0(cruises[1],"_BCS.csv")))

for (i in 2:length(cruises)) {
  fp=file.path(getwd(),cruises[i])
  fn=paste0(cruises[i],"_BCS.csv")
  data=read.csv(file.path(fp,fn))
  alldata=rbind(alldata,data)
  
}

# select unique stations and plot them on the map
ct=cruisetrack_bcs_standard_stations(alldata)

# save cruise trach as html
saveWidget(ct, file=file.path(getwd(),"All_AZMP_stations_1999-2012_circles.html"))

# add andrew's data
afn="Andrew_AZMP_Stations_All.csv"
andrew=read.csv(afn, stringsAsFactors=FALSE)

# add andrew's stations as green circles
ct <- addCircleMarkers(ct, data=andrew, lng=~Lon, lat=~Lat, popup= ~paste0(Station_Name,", ",Source), radius=4, color="green")


blc=c("EVENT_COLLECTOR_STN_NAME","EVENT_SDATE","EVENT_MIN_LAT","EVENT_MIN_LON","EVENT_STIME")
#select unique combinations of station, date, lat and lon
j= which(!duplicated(alldata[,blc]))
# contains unique combinations of station, date, and position
pl=alldata[j,blc]

# unique station names
uns=unique(pl$EVENT_COLLECTOR_STN_NAME)

stgood=pl[1,]
prazno=stgood[-1,]
stgood=prazno
stoutlier=prazno
faraway=prazno
onceonly=prazno


for (i in 1:length(uns)) {
  sti=which(pl$EVENT_COLLECTOR_STN_NAME == uns[i])
  station=pl[sti,]
  
  if (IQR(station$EVENT_MIN_LAT)>0.1 & IQR(station$EVENT_MIN_LON)>0.1) {
    faraway=rbind(faraway,station)
    next
  }
  
  # if there is only one station
  if (length(sti)==1) {
    onceonly=rbind(onceonly,station)
    
  } else{ # if there is more than one station compute boxplot
  
  blat=boxplot(station$EVENT_MIN_LAT,main=paste(uns[i],"LAT, n =",length(sti)),ylab="Latitude")
  blon=boxplot(station$EVENT_MIN_LON,main=paste(uns[i],"LON, n =",length(sti)), ylab="Longitude")
  
  # indices of outliers
  oblat=which(station$EVENT_MIN_LAT %in% blat$out)
  oblon=which(station$EVENT_MIN_LON %in% blon$out)
  
  # indeces of ststions that are outliers
  outofbox=unique(c(oblat,oblon))
  
  # if there are no stations out of box, add them to the good list
  if (length(outofbox)==0) {
    stgood=rbind(stgood,station)
    stoutlier=stoutlier
  }else {
  
  stgood=rbind(stgood,station[-outofbox,])
  stoutlier=rbind(stoutlier,station[outofbox,])
}
} }

# select unique stations and plot them on the map
ct1=cruisetrack_bcs_standard_stations(stgood)

stoutlier$label=paste0(stoutlier$EVENT_COLLECTOR_STN_NAME,", ",stoutlier$EVENT_SDATE," ",stoutlier$EVENT_STIME)
ct1 <- addCircleMarkers(ct1, data=stoutlier, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup=~label, radius=3, color="green")

faraway$label=paste0(faraway$EVENT_COLLECTOR_STN_NAME,", ",faraway$EVENT_SDATE," ",faraway$EVENT_STIME)
ct1 <- addCircleMarkers(ct1, data=faraway, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup=~label, radius=3, color="blue")



# save cruise trach as html
saveWidget(ct1, file=file.path(getwd(),"all_AZMP_stations_average_location.html"))

# aggregate all good stations and compute mean position

standard_loc=aggregate(cbind(EVENT_MIN_LAT,EVENT_MIN_LON) ~EVENT_COLLECTOR_STN_NAME, data=stgood, FUN=mean)

# plot standard stations on the map
m <- leaflet(data=standard_loc)
#m <- addTiles(m)
m <- addTiles(m, urlTemplate='http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}')
#m <- addCircleMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label, radius=4, color="blue")
m <- addMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~ EVENT_COLLECTOR_STN_NAME)

#m <- addPolylines(m, lng = ~EVENT_MIN_LON, lat = ~EVENT_MIN_LAT)

# add standard stations
m <- addCircleMarkers(m, data=ss, lng=~lon, lat=~lat, popup= ~short.name, radius=4, color="red")
m

# ==== add faraway stations ====
faraway$year=year(as.Date(faraway$EVENT_SDATE, format = "%d-%b-%Y"))

# keep only new names
newnames=faraway[which(faraway$year>2005),]

# delete SPB and NL
spb=grep("SPB",newnames$EVENT_COLLECTOR_STN_NAME)
nl=grep("NL",newnames$EVENT_COLLECTOR_STN_NAME)

newnames1=newnames[-c(spb,nl),]

uni=unique(newnames1$EVENT_COLLECTOR_STN_NAME)

for (j in 1:length(uni)) {
  sti=which(newnames1$EVENT_COLLECTOR_STN_NAME == uni[j])
  station=newnames1[sti,]
  blat=boxplot(station$EVENT_MIN_LAT,main=paste(uni[j],"LAT, n =",length(sti)),ylab="Latitude")
  blon=boxplot(station$EVENT_MIN_LON,main=paste(uni[j],"LON, n =",length(sti)), ylab="Longitude")
  
  
}

# aggregate SIB stations
standard_sib=aggregate(cbind(EVENT_MIN_LAT,EVENT_MIN_LON) ~EVENT_COLLECTOR_STN_NAME, data=newnames1, FUN=mean)

standard_azmp=rbind(standard_loc,standard_sib)
standard_azmp$flag=2

# include stations occupied once only
onceonly$flag=1
once=onceonly[,c(1,3,4,7)]

# all azmp
all_azmp=rbind(standard_azmp,once)

write.csv(standard_azmp,"AZMP_station_average_locations.csv")

write.csv(all_azmp,"all_AZMP_standard_locations_including_once_occupied.csv")

m <- leaflet(data=all_azmp)
#m <- addTiles(m)
m <- addTiles(m, urlTemplate='http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}')
#m <- addCircleMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~label, radius=4, color="blue")
m <- addMarkers(m, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~ EVENT_COLLECTOR_STN_NAME)

m <- addCircleMarkers(m, data=once, lng=~EVENT_MIN_LON, lat=~EVENT_MIN_LAT, popup= ~ EVENT_COLLECTOR_STN_NAME, radius=4, color="green")

# add the stations that are occupied only once


