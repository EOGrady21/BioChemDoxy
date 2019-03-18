# Get mission info from osccruise database
# Requires osccruise function
# IMPORTANT: THE INPUT IS CRUISE NUMBER LIKE HUD2004016
#
# Written by Gordana Lazin, BioChem Reboot Project, 2015

mission_info <- function(mission) {

osc=osccruise(mission) # extract mission data from osccruise database, it can have more than one leg
osc0=osc # just to have for the control

osc$COMMENTS="" #remove content of comment field

# check if mission has more than one leg
if (length(osc$LEG) >1) {
  oscm=osc[!is.na(osc$MISSION_DESCRIPTOR),]
  oscm=oscm[1,] # osccruise for multiple legs
  
  leg=osc$LEG # column with legs
  
  # find legs that are numeric: 0,1,2,3,... (leg can also be UK)
  numlegs=as.numeric(leg[grep("[[:digit:]]",leg)]) # legs as numbers (leg can also be 0 or UK)
  legi=which(osc$LEG %in% as.character(numlegs)) #find indices of the rows in osc where the legs are
  
  # if there is only one numeric leg, pick that one (it doesn't matter if it is 0)
  if (length(numlegs)==1) {
    oscm=osc[legi,]

  }
  
  
  # if there is more than one numeric leg
  if(length(numlegs)>1) {
    
    # find how many legs are not zero
    legs=numlegs[numlegs>0] # legs that are numeric and not zero
    legi=which(osc$LEG %in% as.character(legs)) #find indices of the rows in osc where the legs are
    
    # if there is only one non zero leg, pick that one
    if (length(legs)==1) {
      oscm=osc[legi,]
    }
    
    # otherwise, if there is more than one non-zero leg
    oscm$MISSION_SDATE=osc$MISSION_SDATE[osc$LEG==as.character(min(legs))] # start date is yhe start date of min leg number
    oscm$MISSION_EDATE=osc$MISSION_EDATE[osc$LEG==as.character(max(legs))] # end date is the end of the last leg
    oscm$MISSION_LEADER=paste(unique(osc$MISSION_LEADER[legi]), collapse="-") # names of all chief scientists on all legs
    oscm$COMMENTS=paste("THIS CRUISE HAD", as.character(length(legs)), "LEGS")
    
  }  
  
  osc=oscm
}

return(osc)
}
