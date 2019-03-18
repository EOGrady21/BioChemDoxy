# bathyimtry

require(marmap)

# set working directory, whatever it is
wd="C:/Gordana/BioChem-HUD2013004/R"
setwd(wd)

# load AZMP standard stations
stations=read.csv("AZMP_Stations_Definition.csv", stringsAsFactors=FALSE)



# ==== bathymetry data from NOAA at 4deg resolution =====
# this is how to get bathymertry from NOAA, query the database
bio_depth<-getNOAA.bathy(-70, -41, 41, 56)

# define colors
blues <- c("darkblue","lightblue","cadetblue1","white")

# plot map
plot(bio_depth, n=0,image = TRUE, land = TRUE, axes=FALSE, lwd = 0.1,
     bpal = list(c(0, max(bio_depth, na.rm=T), "grey"),
                 c(min(bio_depth, na.rm=T),0,blues)))

# plot points (azmp stations)
points(stations$lon,stations$lat,col="red")
# == done with NOAA, plots fairly quickly ===





#==== GEBCO nc file has to be downloaded first =====
# this is GEBCO file in 30 sec resolution, needs to be downloaded
gebco_path="E:/ODS_toolbox/ODS2/Trunk/ODSTools/NetCDF"
gebcofn="GEBCO_2014_2D_-100.0_35.0_-40.0_80.0.nc"

gebco_file=file.path(gebco_path,gebcofn)

# this is how to read GEBCO
nwa=readGEBCO.bathy(gebco_file)
summary(nwa) # the bathymetry data

# this is how to get depth for set of lat and lon
a=get.depth(nwa,stations$lon, stations$lat, locator=FALSE)

# this is how to subset bathymetry data
azmp_lat=c(41,41,56,56) # latitude of the corners of the box
azmp_lon=c(-70,-41,-41,-70) # longitudes of the corners
azmp_bathy=subsetBathy(nwa, x=azmp_lon, y=azmp_lat, locator=FALSE)

# this is again colors
blues <- c("darkblue","lightblue","cadetblue1","white")


# Plotting the bathymetry with different colors for land and sea
plot(azmp_bathy, n=0,image = TRUE, land = TRUE, axes=TRUE,lwd = 0.1,
     bpal = list(c(0, max(azmp_bathy, na.rm=T), "grey"),
                 c(min(azmp_bathy, na.rm=T),0,blues)))

# plot azmp stations
points(stations$lon,stations$lat,col="red")

# == done with GEBCO, plotting chokes my computer, try lower resolution ==

# not sure how to deal with axes. if you put axis=TRUE then the image is smaller than the axis box.
# if you strech the image the axis box streches but the image stays the same???

# ANOTHER TRY FOR THE MAP
# Creating a custom palette of blues
blues <- c("lightsteelblue4", "lightsteelblue3",
           "lightsteelblue2", "lightsteelblue1")
depth=bio_depth

# Plotting the bathymetry with different colors for land and sea
plot(depth, image = TRUE, land = TRUE, lwd = 0.1,axes=FALSE,
     bpal = list(c(0, max(depth), "grey"),
                 c(min(depth),0,blues)))

# another try

papoue=depth
blues <- c("lightsteelblue4", "lightsteelblue3",
           "lightsteelblue2", "lightsteelblue1","lightblue","lightcyan")
greys <- c(grey(0.6), grey(0.93), grey(0.99))
1
plot(papoue, n=0,image = TRUE, land = TRUE, lwd = 0.03,
     bpal = list(c(0, max(papoue), greys),
                 c(min(papoue), 0, blues)))


