# fix CTD metadata: replace ctd number with event number


# event log was created by hand for this cruise.
cruise="HUD2003078"
map_file="C:/Gordana/Biochem_reload/qat_fix/HUD2003078/HUD2003078_BiolSum.xls"
sheet="BIOLSUMS_FOR_RELOAD"

# metadata file
metadata="C:/Gordana/Biochem_reload/qat_fix/HUD2003078/HUD2003078_CTD_Metadata.xlsx"


# define the directory to writ out the output
out_path=paste0("C:/Gordana/Biochem_reload/qat_fix/", cruise )

# ==== DETERMINE RELATIONSHIP BETWEEN CTD CAST AND EVENT ======
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

# ==== ctd_event variable has a relationship between ctd and event =====

# now load CTD metadata
meta=read.xlsx(metadata, stringsAsFactors=FALSE, sheetName ="ODF_INFO") 

mm=merge(meta,ctd_event, by.x="Event_Number", by.y="ctd", all.x=T, all.y=F)

# replace CTD number with event number

mm$Event_Number=mm$event

# remove extra columns
hh=subset(mm, select=-c(event, station))

# order columns the same as in original metadata
hh=hh[,names(meta)]

# write out new metadata file in xls format
write.xlsx(hh,file.path(out_path,"fixed_metadata.xlsx"), sheetName="ODF_INFO", row.names=FALSE)



