# get the list of the cruises

cruises=read.csv("ellen_cruises.csv", stringsAsFactors=FALSE)

cruises_info=NULL
for(i in 1:dim(cruises)[1]) {
  
  cr=osccruise(cruises[i,1])
  
  if (dim(cr)[1]==0){
    cr[1,]=NA
    cr$MISSION_NAME=cruises[i,1]
  }
  
  cruises_info=rbind(cruises_info,cr)
}
  

write.csv(cruises_info,"ellen_osccruise_list.csv", quote=FALSE)
