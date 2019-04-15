# fix QAT files that have CTD number in the file name and in the event column insted of event number. 
# Replace CTD number with Event number in the file and in the file name

wd="C:/Gordana/Biochem_reload/working" # at work
setwd(wd)

require(xlsx) #loads xlsx package
source("substrRight.r")

# edit these 3 lines for each cruise
# cruise="HUD2000050"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2000050/HUD2000050_BRIDGELOG.xlsx"
# sheet="BRIDGELOG_FOR_RELOAD"

# cruise="HUD2001009"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2001009/bridgelog_QC.xls"
# sheet="BRIDGELOG_FOR_RELOAD"

# cruise="HUD2003005"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2003005/bridgelog_03005.xls"
# sheet="EVENTLOG"

# cruise="HUD2004009"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2004009/HUD2004009_Biolsum.xls"
# sheet="BIOLSUMS_FOR_RELOAD"

#  cruise="NED2005004"
#  map_file="C:/Gordana/Biochem_reload/qat_fix/NED2005004/NED2005004_CHL_BiolSum_GL.xls"
#  sheet="BIOLSUM_FOR_RELOAD"


# event log was created by hand for this cruise.
# cruise="PAR2000002"
# map_file="C:/Gordana/Biochem_reload/qat_fix/PAR2000002/PAR2000002_eventlog_created.xlsx"
# sheet="BRIDGELOG_FOR_RELOAD"

# event log was created by hand for this cruise.
# cruise="HUD1999054"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD1999054/HUD99054BRIDGELOG.xls"
# sheet="BRIDGELOG_FOR_RELOAD"

# event log was created by hand for this cruise.
# cruise="HUD1999003"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD1999003/HUD99003_BRIDGELOG.xlsx"
# sheet="BRIDGELOG_FOR_RELOAD"

# event log was created by hand for this cruise.
# cruise="HUD2002064"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2002064/HUD2002064_BiolSum.xls"
# sheet="BIOLSUMS_FOR_RELOAD"

# event log was created by hand for this cruise.
# cruise="HUD2001061"
# map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2001061/HUD2001061_BiolSum.xls"
# sheet="BIOLSUMS_FOR_RELOAD"

# event log was created by hand for this cruise.
cruise="HUD2003078"
map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2003078/HUD2003078_BiolSum.xls"
sheet="BIOLSUMS_FOR_RELOAD"



# define the directory containing qat files
qat_path=paste0("C:/Gordana/Biochem_reload/qat_fix/", cruise ,"/qat_file/")
out_path=paste0("C:/Gordana/Biochem_reload/qat_fix/", cruise ,"/qat_event/")

# make a list of qat files including path
fl=list.files(path=qat_path, pattern=".qat", full.names=TRUE)
ql=list.files(path=qat_path, pattern=".qat", full.names=FALSE) # list of qat filenames only without the path

# read map file to find which CTD cast is associated with an event
bs=read.xlsx(map_file, sheetName=sheet, stringsAsFactors=FALSE)

# find columns that have ctd and event titles
names(bs)=tolower(names(bs)) # make all column headers lower case
ictd=grep("ctd",names(bs), ignore.case=TRUE) # find column with CTD title
ievent=grep("event",names(bs), ignore.case=TRUE) # find column with event title
istn=grep("station",names(bs), ignore.case=TRUE) # find column with station title

# in case the column heading is stn insted of station
if (length(istn)==0) {
  istn=grep("stn",names(bs), ignore.case=TRUE) # find column with station title
}

# find rows with ctd casts
ctd_casts=which(!is.na(bs$ctd))

# find unique combination of ctd and event
ctd_event=unique(bs[ctd_casts,c(ictd,ievent,istn)])



# check if there are duplicated ctd casts or duplicated events
if (length(which(duplicated(ctd_event$ctd)))>0) {
  cat("\n","Duplicated CTD cast numbers in the mapping file")
  stop()
}

if (length(which(duplicated(ctd_event$event)))>0) {
  cat("\n","Duplicated event number in the mapping file")
  stop()
}


# read all the files one by one, replace CTD number with EVENT, 
# save the file with EVENT in the file name

for (i in 1:length(fl)) {
 
  # read qat file:
 q=read.table(fl[i],sep=",", stringsAsFactors=FALSE, strip.white=TRUE) #q is a dataframe with data from single qat file
 j=which(ctd_event$ctd==q$V2[1]) #find event associated with CTD number
 
 event=sprintf("%03d", ctd_event$event[j]) #event with leading zeroes
 
 q$V2=event # replace CTD number by event number
 
 # create file name
 cr=substr(ql[i],1,3)
 cast=toupper(substr(ql[i],4,4))
 
 fn=paste0(out_path,cr,cast,event,".QAT") # create file name
 
 write.table(q,file=fn, col.names=FALSE, row.names=FALSE, sep=", ", quote=c(7,8)) #quote only date and time colums
}


# write out the ctd-event map 
map_name=paste0(out_path,cruise,"_ctd_event_map.csv")

# rename columns so it can work with Jeff's script
names(ctd_event)=c("CTD","EVENT","STN")
write.table(ctd_event,file=map_name,sep=",",row.names=FALSE)

# get metadata from OSCCRUISE and write it to the file

