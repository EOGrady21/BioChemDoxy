# Function that renames stations to standard notation: HL2 to HL_02 or HL4.5 to HL_04.5
# If the name has no numerical characters it would leave it like it is
# It cannot handle the station names where numbers and characters are mixed up:
# like BANQ_B01 or HL_02F or GBL1_02 so those are coded as exeption.
#
# Written by Gordana Lazin, for BioChem Reboot project, 2015



rename_stations <- function(stNames) {
  
  # find indices of station names that have more than 9 characters
  long=which(nchar(stNames)>8)
  long_names=stNames[long]
  
  # remove undescores from station names if they exist
  stNames=gsub("_","",stNames)
  
  # this works perfect- extracts station names only including spaces and special characters
  ch4=gsub("[[:digit:]]","",stNames)
  ch5=gsub("[.]","",ch4)

  # extract numbers from string (including dots)
  nu=gsub("[[:alpha:]]","",stNames) # works good except it contains special characters
  nu=gsub("/","",nu) # have to remove each character separately as I want to keep the period
  nu=gsub("_","",nu)
  nu=gsub("-","",nu)
  nu=gsub(" ","",nu)

  # separate characters before and after period "."
  p=regexpr("[.]",nu)
  p[p<0]=NA #replace -1 with NA

  # characters after period
  ap=substr(nu,p,nchar(nu))
  ap[is.na(ap)]="" #replace NA with empty string

  # characters before period
  bp=substr(nu,1,p-1)
  bpn=is.na(bp)
  bp[bpn]=nu[bpn] #replace NA with nu

  # which are numbers and not empty
  nums=which(bp!="")

  # add leading zeroes
  bp[nums]=sprintf("%02d",as.numeric(bp[nums]))
  bp[nums]=paste0("_",bp[nums]) #add underscore before numbers


  # now add all together
  station_names=paste0(ch5,bp,ap)
  
  # if there are two underscores remove one
  station_names=gsub("__","_",station_names)
  
  # remove NANA
  station_names=gsub("NANA","",station_names)
  
  # replace GULDD with GULD
  station_names=gsub("GULDD","GULD",station_names)
  
  # replace GULLY with GULD
  station_names=gsub("GULLY","GULD",station_names)
  
  # replace HL_00 with HL_0
  station_names=gsub("HL_00","HL_0",station_names)
  
  # replace BBASIN with HL_0
  station_names=gsub("BBASIN","HL_0",station_names)
  
  # replace BB with HL_0
  station_names[which(station_names=="BB")]="HL_0"
  
  # replace all double zeroes with one zero
  station_names=gsub("_00","_0",station_names)
  
  # EXCEPTION 1: station names that have letters in the end, like HL2A - rename to HL_02A
  p=substrRight(stNames,2) # extract last two characters in station mames
  is=grep("(.*[[:digit:]].*[[:alpha:]])",p) # indices of stations that have letters after numbers, like 2A
  nup=gsub("[[:alpha:]]","",stNames[is]) # extract station number
  nupn=sprintf("%02d",as.numeric(nup)) # ad leading zero to station number
  ending=paste0("_",nupn,substrRight(stNames[is],1))
  # keep working on it
  # station names only -- remove one character from satation name
  kk=nchar(ch4[is])-1
  stis=substr(ch4[is],1,kk) # station names for those station that have letter in the end
  station_names[is]=paste0(stis,ending)
  
  # EXCEPTION 2: Stations GBL1_01 and GBL2_01
  # abort for now: not sure if GBL11 is GBL1_01 or GBL_11
  igbl1=grep("GBL1",stNames, ignore.case=TRUE) # indices of stations with GBL1
  igbl2=grep("GBL2",stNames, ignore.case=TRUE) # indices of stations with GBL2
  igbl=c(igbl1,igbl2) # indices of stations with GBL1 and GBL2

  if (length(igbl>0)) {
  # extract numbers from igbl
  nup_gbl=gsub("[[:alpha:]]","",stNames[igbl]) # extract station number
  nc=nchar(nup_gbl) # number of characters in numbers
  gbl_stnum=substr(nup_gbl,2,nc)
  #gbl_stnum=sprintf("%02d",as.numeric(gbl_stnum))
  gbl_stnum=formatC(as.numeric(gbl_stnum), digits=3, flag=0) #add leading zeroes to all. Integers will now have 3 leading zeoes
  gbl_stnum=gsub("000","0",gbl_stnum) #remove extra zeroes from integers

  # station name is the first four characters
  stn_gbl=substr(stNames[igbl],1,4)

  station_names[igbl]=paste0(stn_gbl,"_",gbl_stnum)
  }
  
  
  # EXCEPTION 3: Stations BANQ_B01
ibb=grep("BANQ",stNames, ignore.case=TRUE) # indices of stations that have BANQ
nubb=sprintf("%02d",as.numeric(nu[ibb])) # ad leading zero to station number
if (length(ibb)>0) {
# extract station letter from the name  
s1=gsub("BANQ","",stNames[ibb]) # 1. get rid of the BANQ
s2=gsub("[[:digit:]]","",s1) # 2. get rid of the digits
s3=gsub("[[:punct:]]","",s2) # 3. get rid of the punctuations; left over is station letter s3




  station_names[ibb]=paste0("BANQ_",s3,nubb)}

# write long station names in original format
station_names[long]=long_names


  return(station_names)
}