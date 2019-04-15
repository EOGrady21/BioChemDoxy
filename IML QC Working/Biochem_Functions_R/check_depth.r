# bathyimtry

require(marmap)


# set working directory, whatever it is
wd="C:/Gordana/BioChem-HUD2013004/R"
setwd(wd)

# load AZMP standard stations
stations=read.csv("AZMP_Stations_Definition.csv", stringsAsFactors=FALSE)

#this is GEBCO file in 30 sec resolution, needs to be downloaded
gebco_path="E:/ODS_toolbox/ODS2/Trunk/ODSTools/NetCDF"
gebcofn="GEBCO_2014_2D_-100.0_35.0_-40.0_80.0.nc"

gebco_file=file.path(gebco_path,gebcofn)

# this is how to read GEBCO
nwa=readGEBCO.bathy(gebco_file)
summary(nwa) # the bathymetry data

# this is how to get depth for set of lat and lon
a=get.depth(nwa,stations$lon, stations$lat, locator=FALSE)


# createe boxes around the stations, and compute range of depths from depths in the corners
# has to be done for each line in the header that has sounding

# add two columns in station for min and max depth in the box
stations$gebco_depth=NA
stations$min_depth=NA
stations$max_depth=NA
stations$min_box=NA
stations$max_box=NA

for (i in 1: dim(stations)[1]) {

lat=stations$lat[i]
lon=stations$lon[i]

# r is distance in degrees from the station location (0.01 deg is about 1 km, or 850m in lon and 1.11 km in lat)
r=0.1
# corner latitudes
clat=c(lat,lat+r, lat+r, lat-r, lat-r) # center and the corners of latitude
clon=c(lon,lon+r, lon-r, lon-r, lon+r)  # center and corners of longitude

# get depth on the corners of the box
d=get.depth(nwa,clon,clat, locator=FALSE)

# depth at the station location
sl=get.depth(nwa,lon,lat, locator=FALSE)
stations$gebco_depth[i]=-sl$depth

# min and max depth of the corners and the center of the box
stations$min_depth[i]=min(-d$depth, na.rm=TRUE)
stations$max_depth[i]=max(-d$depth, na.rm=TRUE)


# alternative method: min and max of all points within the box
clat=c(lat+r, lat+r, lat-r, lat-r) # center and the corners of latitude
clon=c(lon+r, lon-r, lon-r, lon+r)  # center and corners of longitude

# subset to the small box
smb=subsetBathy(nwa,x=clon,y=clat, locator=F)

# min amd max within the box
stations$min_box[i]=-max(smb,na.rm=TRUE)
stations$max_box[i]=-min(smb,na.rm=TRUE)

# comment: corners of the box give different range than the poins within box
# possibly due to different procedures/functions for data extraction??? 
}


# add line to the stations
stations$line=gsub("[[:digit:]]","",stations$short.name)
stations$st_number=as.numeric(gsub("[[:alpha:]]","",stations$short.name))

# percentage diference between standard depth and gebco depth
stations$p=100*(1-stations$gebco_depth/stations$depth)

# plot histogram of the differences
hist(stations$p,100, col="dodgerblue", 
     xlab="% difference:depth vs, GEBCO", main="AZMP standard stations")


require(lattice)
# plot difference for each line: for AZMP stations only
xyplot(p~st_number|line, data=stations, as.table=T, col="blue",xlab="Station number", 
       ylab="% difference", main="% Difference between standard depth and GEBCO depth",
       panel=function(...) {
         panel.xyplot(...)
         panel.grid(h=-1,v=-1)
         panel.abline(h=0, col="gray")
       })

# plot ranges for each line separately
ul=unique(stations$line)

for (i in 1:length(ul)) {
  
  j=which(stations$line==ul[i])
  
  tit=paste(ul[i], "Line: Depth of stations +- 0.1deg")
  plot(stations$depth[j], type="b", xlab="Station number",ylab="Depth [m]", main=tit,
       ylim=c(min(0.7*stations$gebco_depth[j]),max(1.3*stations$gebco_depth[j])))
  points(stations$gebco_depth[j], col="blue", pch=19)
  points(stations$min_depth[j], col="red", pch="-", cex=2)
  points(stations$max_depth[j], col="red", pch="-", cex=2)
  
  points(stations$min_box[j], col="green", pch="-", cex=2)
  points(stations$max_box[j], col="green", pch="-", cex=2)
  
  
  #points(1.2*stations$gebco_depth[j], col="green", pch="-", cex=2)
  #points(0.8*stations$gebco_depth[j], col="green",pch="-", cex=2)
  
  #points(1.25*stations$gebco_depth[j], col="magenta", pch="-", cex=2)
  #points(0.75*stations$gebco_depth[j], col="magenta",pch="-", cex=2)
  
}
  
  
  

plot(stations$depth, type="b", ylab="Depth [m]", main="Depth for core AZMP stations, +- 0.02 deg")
points(stations$gebco_depth, col="blue", pch=19)
points(stations$min_depth, col="red", pch="-", cex=2)
points(stations$max_depth, col="red", pch="-", cex=2)

prc_min=1-stations$gebco_depth/stations$min_depth
prc_max=1-stations$gebco_depth/stations$max_depth

plot(prc_min*100, type="b", col="red", main="Percentage difference from gebco depth within the 0.01deg box")
points(prc_max*100, col="blue")


# see how many are out of range
us=unique(stations)

outrange=which(us$depth<us$min_depth | us$depth>us$max_depth)

outrange1=which(us$depth<us$min_box | us$depth>us$max_box)
