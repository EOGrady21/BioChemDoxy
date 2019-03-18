# Extract metadata for the list of cruises

filename='cruise_list_reboot.xlsx'

cruises=read.xlsx(filename, stringsAsFactors=FALSE, sheetName ="cruise_list")

# use only azmp cruises
n=1:32

azmp=cruises[n,];

# remove empty rows
azmp=azmp[!is.na(azmp$Regional.Mission.ID),]

# remove years 2013 and up
azmp=azmp[azmp$Year<2013,]

# make metadata table

meta=azmp[1,]
meta=meta[-1,]

for (i in 1:dim(azmp)[1]) {
 
  m=mission_info(azmp$Regional.Mission.ID[i])
  
  meta=rbind(meta,m)
  
}

# export metadata

write.csv(meta,"azmp_metadata_osc.csv",row.names=FALSE,na="")
