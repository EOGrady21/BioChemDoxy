# check bathymetry using GEBCO data. Input is lat and lon. Output is the min and max depth 
# in a box around lat and lon. Size of the box is set to 0.1 deg but can be changed

gebco_depth_range <- function(slat,slon) {

  # find NA from lat and lon
  ind=unique(which(is.na(slat)),which(is.na(slon)))
  
  # if there are any NA remove them
  if (length(ind)>0) {  
    slat=slat[-ind]
    slon=slon[-ind]
  }
  
  
  # r is size of the box, i.e. distance in degrees from the station location 
  # 0.01 deg is about 1 km (850m in lon and 1.11 km in lat)
  # 0.1 deg is about 10 km (8.5 km in lon and 11.1 in lat)
  r=0.1


  #this is GEBCO file in 30 sec resolution, needs to be downloaded
  gebco_path="C:/ODS_Toolbox/ODS2/NetCDF"
  gebcofn="GEBCO_2014_2D_-100.0_35.0_-40.0_80.0.nc"

  gebco_file=file.path(gebco_path,gebcofn)

  # this is how to read GEBCO
  nwa=readGEBCO.bathy(gebco_file)


  # create boxes around the stations, and compute min and max depth in the box
  # has to be done for each line in the header that has sounding

  # add two columns in station for min and max depth in the box
  gebco_sounding=NA
  min_gebco=NA
  max_gebco=NA
  
  #

  for (i in 1:length(slat)) {

  lat=slat[i]
  lon=slon[i]


  # depth at the station location
  sl=get.depth(nwa,lon,lat, locator=FALSE)
  gebco_sounding[i]=-sl$depth


  # create a small box 2rx2r around location 
  clat=c(lat+r, lat+r, lat-r, lat-r) # corners of latitude box
  clon=c(lon+r, lon-r, lon-r, lon+r)  # corners of longitude box

  # subset using small box
  smb=subsetBathy(nwa,x=clon,y=clat, locator=F)

  # min amd max within the box
  min_gebco[i]=-max(smb,na.rm=TRUE)
  max_gebco[i]=-min(smb,na.rm=TRUE)
  
}

depth_range=data.frame(slat,slon,gebco_sounding,min_gebco,max_gebco)

# replace the depth <0 (above the sea level) with zero
depth_range$min_gebco[which(depth_range$min_gebco<0)]=0

return(depth_range)
}
