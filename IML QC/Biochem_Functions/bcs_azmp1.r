# Prepare discrete bottle data for loading to BioChem:
# merge discrete bottle data from $ files: bridge log, BiolSum, CTD QAT file and ODF headers data
# create BCS header file with metadata file

# Method: 
# load and check all 4 files for inconsistencies (Bridge Log, QAT file, BiolSum and CTD metadata)
# convert all the dates to R date-time format
# merge the files based on sample ID and event number
# Create start end end dates and time columns using info from QAT files and bridge log
# create start and end lon and lat using info from QAT file and bridge log
# pick the columns for header file and create header file
# pick the columns for data file and create data file

# !!! IMPORTANT: have to edit FILES TO LOAD, and column names for Bridge Log and BiolSum !!!

# set woring directory
#wd="C:/Users/Goga/Dropbox/Goga/BioChem-HUD2013004/R" #from home
wd="C:/Gordana/Biochem_reload/working" # at work
setwd(wd)

# to read data from excel files need to install xlsx package
# xlsx package does not work on my laptop at home, so I saved files as csv, and used read.csv 
# read.xlsx works at BIO, so xls files can be imported directly

#install.packages("xlsx") #uncoment this line if you need to install xlsx package
require(xlsx) #loads xlsx package
require(lubridate)
require(marmap)
require(htmlwidgets)
source("format_time.r")
source("format_date.r")
source("osccruise.r")
source("gebco_depth_range.r")
source("na.rows.r")
source("rename_stations.r")
source("bctime.r")
source("substrRight.r")
source("clean_xls.r")
source("check_biolsum1.r")
source("check_bridgeLog.r")
source("check_qat1.r")
source("check_ctd_metadata.r")
source("clr.r")
source("mkdirs.r")
source("mission_info.r")
source("is.installed.r")
source("cruisetrack_bcs.r")
source("cruisetrack_bcs_standard_stations.r")
source("convert2gmt.r")

# ====================#
# DEFINE FILES TO LOAD
# ====================#

mission="HUD2003067"  #this has to be changed manually for each mission
protocol="AZMP"
DIS_HEADR_DATA_MANAGER_COMMENT=""

# add data manage comment for particular cruise
if (mission=="HUD2008004") {
DIS_HEADR_DATA_MANAGER_COMMENT= "Noted by Jeff Spry: CTD data need recalibration-particularly oxy-less for temp and sal."
} 

# or mission and protocol can be provided interactively:
#mission=readline("Input MISSION DESCRIPTOR (example 18HU12042):")
#protocol=readline("Input mission PROTOCOL (example AZMP, or AZOMP):")

# this file "Files_for_DIS_header.csv" contains list of files to be loaded
# the file is now on the data by year and cruise folder in Src
fp="//ent.dfo-mpo.ca/ATLShares/Science/BIODataSvc/SRC/BIOCHEMInventory/Data_by_Year_and_Cruise/Files_for_DIS_header.csv"
files=read.csv(fp, stringsAsFactors=FALSE)

# select files for this particular mission
files=files[files$mission==mission,]

Bridge_log=file.path(files$path,files$Bridge_log)
BiolSum=file.path(files$path,files$BiolSum)
qatFile=file.path(files$path,files$qatFile)
odfFile=file.path(files$path,files$odf)

# create a directory in the current folder with the cruise name
mkdirs(mission)
outpath=file.path(wd,mission)

# =================== #
# DEFINE REPORT FILE
# =================== #

n=now() # make time stamp to mark the start of processing
timestamp=paste0(year(n), sprintf("%02d",month(n)),sprintf("%02d",day(n)),
                 sprintf("%02d",hour(n)),sprintf("%02d",minute(n)),sprintf("%02d",floor(second(n))))

# name of the report file                 
report_file=paste0(mission,"_BCS_report_",timestamp, ".txt")
report_file=file.path(outpath,report_file)

# write input files into report
sink(file=report_file,append=TRUE, split=TRUE)
cat("\n")
cat(paste(mission,"metadata QC log, ", n))
cat("\n")
cat(c("-------","\n","\n"))

cat("Input file:", Bridge_log)
cat("\n")
cat("Input file:", BiolSum)
cat("\n")
cat("Input file:", qatFile)
cat("\n")
cat("Input file:", odfFile)
sink()

# define an issue counter
issues=0


# ================#
# Check BRIDGE LOG
# ================#


# Bridge_log is file name, and check_bridgeLog is a function for QC
blog_header=check_bridgeLog(Bridge_log)

blog_issues=which(blog_header$flag_bl==99)

# =============#
# Check BiolSum 
# =============#

# BiolSum is file name, and check_biolsum1 is a function for QC
bsum_flagged=check_biolsum1(BiolSum)

# biolsum with regular sample IDs
bsum_header=bsum_flagged[which(bsum_flagged$flag != 2),]

bsum_flagged$dmcomment=bsum_flagged$dmcomment_bs

# check if there is NA in depth column. This is an issue.
na_depth=which(is.na(bsum_flagged$depth_bs) & bsum_flagged$id_bs==999999)

# if there is a NA depth write warrning
if (length(na_depth)>0) {
  issues=issues+1
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste("-> BiolSum Check: Issue", issues,": BiolSum depth is NA for following casts:"))
  cat("\n","\n")
  print(bsum_flagged[na_depth,1:10])
  sink()
}

# lines with duplicate regular sample IDs
bsum_issues=c(which(bsum_header$flag_bs==99),na_depth)

# dataframe with test events
bsum_tests=bsum_flagged[which(bsum_flagged$flag == 2),]

# ===================================#
# read ODF header file (CTD Metadata) 
# ===================================#

# function returns a list
odf_list=check_ctd_metadata(odfFile)

odf_info=odf_list$odf_info #one line data frame with all mission information from odf header. 
odf_header=odf_list$odf_header #dataframe containing CTD metadata that will be used in the header


# ==============#
# read QAT file 
# ==============#

# flagged qat file: 2 is test casts, 99 is duplicates, 0 is ok
qat_flagged=check_qat1(qatFile)

# ===== TIME CHANGES FOR QAT ======
# some cruises have local time in QAT files instead of UTC
# the offset will be applied here
local_time_missions=c("HUD2011004","HUD2001061")
if (mission %in% local_time_missions) {
  # change QAT time
  qat_flagged$date_time_qat=convert2gmt(qat_flagged$date_time_qat) # assigns Atlantic time zone to the time, does not change time
  
  # change the last bottle time
  qat_flagged$last_bottle_datetime_qat=convert2gmt(qat_flagged$last_bottle_datetime_qat) # assigns Atlantic time zone to the time, does not change time
 
  #qat_flagged$date_time_qat=qat_flagged$date_time_qat+3*3600 # add 3 hours offset
  #qat_flagged$last_bottle_datetime_qat=qat_flagged$last_bottle_datetime_qat+3*3600
}

# some cruises did not have time zone set up as GMT on the logging computer and the time flipped back in the fall for 1 hr. 
# time has to be corrected only for the part of the cruise after DST change (add one hour).
dst_missions=c("HUD99054")
fall_back=as.POSIXct("1999-11-01 00:00:00 GMT", tz="GMT")
indm=which(dst_missions==mission)

if  (mission %in% dst_missions) {
  aft=which(qat_flagged$date_time_qat>fall_back[indm])
  qat_flagged$date_time_qat[aft]=qat_flagged$date_time_qat[aft]+3600
  qat_flagged$last_bottle_datetime_qat[aft]=qat_flagged$last_bottle_datetime_qat[aft]+3600
}
# ========================

# dataframe with test data
qat_tests=qat_flagged[which(qat_flagged$flag ==2),]

# dataframe with regular data
qat_header=qat_flagged[which(qat_flagged$flag != 2),]

# issues in regular data (duplicates of regular samples)
qat_issues=which(qat_header$flag_qat==99)

# --- track issues ----#
no_issues=length(c(blog_issues,bsum_issues,qat_issues))

# flag for the issues in the individula files
issue_files=0
# if there are issues in individual files set issue_files to 1
if(no_issues>0){
  issue_files=1
}


# =================================================================================================#
# compare QAT and BIolSum events and Sample ID before merging: ordinary sample ID with bottle data
# =================================================================================================#

# how many events are in bsum, qat, blog and odf
n_bsum=length(unique(bsum_header$event_bs))
n_qat=length(unique(qat_header$event_qat))

# check if there are EVENTS in qat that are not in bsum
events_not_in_bsum=setdiff(unique(qat_header$event_qat),unique(bsum_header$event_bs))
events_not_in_qat=setdiff(unique(bsum_header$event_bs),unique(qat_header$event_qat))

# print the message on the screen if there is difference in number of events
sink(file=report_file,append=TRUE, split=TRUE)
if (length(events_not_in_qat)>0 | length(events_not_in_bsum)>0) {
  issues=issues+1
  cat("\n","\n")
  cat(paste("-> Cross Check: Issue", issues, "- Events in QAT and BiolSum file are not the same"))
  cat("\n","\n")
  cat(paste("-> Number of events in QAT file:", n_qat))
  cat("\n","\n")
  cat(paste("-> Number of events in BiolSum file:", n_bsum))
  cat("\n","\n")
  
  if (length(events_not_in_bsum)>0){
  cat(paste("->", length(events_not_in_bsum), " Events not in BiolSum:"))
  cat("\n","\n")
  print(qat_header[which(qat_header$event_qat %in% events_not_in_bsum),],row.names = FALSE)
  }

  if (length(events_not_in_qat)>0) {
  cat("\n","\n")
  cat(paste(length(events_not_in_qat)," Events not in QAT file:"))
  cat("\n","\n")
  print(bsum_header[which(bsum_header$event_bs %in% events_not_in_qat),],row.names = FALSE)
  }
  
} else { 
  cat("\n","\n")
  cat("-> Cross Check: Events in QAT and BiolSum are the same.")}
sink()


# check if there are any SAMPLE ID qat that are not in bsum
id_not_in_bsum=setdiff(unique(qat_header$id_qat),unique(bsum_header$id_bs))
id_not_in_qat=setdiff(unique(bsum_header$id_bs),unique(qat_header$id_qat))

# if there are events missing print the message on the screen
sink(file=report_file,append=TRUE, split=TRUE)
if(length(id_not_in_bsum)>0) {
  issues=issues+1
  cat("\n","\n")
  cat(paste("-> Cross Check: Issue",issues, "-","Sample ID found in QAT file but not in BiolSum:"))
  cat("\n","\n")
  print(qat_header[which(qat_header$id_qat %in% id_not_in_bsum),c(5,1:4,6:9)],row.names = FALSE)
} else {
  cat("\n","\n")
  cat("-> Cross Check: All Sample IDs from QAT are found in BiolSums.") }


if(length(id_not_in_qat)>0) {
  issues=issues+1
  cat("\n","\n")
  cat(paste("-> Cross Check: Issue",issues, "- Sample ID found in BiolSum but not in QAT:"))
  cat("\n","\n")
  print(bsum_header[which(bsum_header$id_bs %in% id_not_in_qat),c(8,1:7,9)],row.names = FALSE)
} else {
  cat("\n","\n")
  cat("-> Cross Check: All Sample IDs from BiolSum are found in QAT.") 
  
}
sink()

# check if there is any data in BiolSums for that sample ID
#bo=which(bsum_original$ID_TAG %in% id_not_in_qat)
#bsum_original[bo,]

# done with QAT vs. BiolSums comparison

# decide to proceed with merging or not

# if (issues>0 | issue_files>0) {
#   sink(file=report_file,append=TRUE, split=TRUE)
#   cat("\n","\n")
#   cat("-> Cannot proceed. Please investigate reported issues.")
#   sink()
#   stop()
# } 


# sink(file=report_file,append=TRUE, split=TRUE)
#   cat("\n","\n")
#   cat("-> No issues detected so far. Continue with file merging...")
# sink()

# =================================================================================================#
# compare QAT and BIolSum events and Sample ID before merging: CTD casts without bottle data (tests)
# =================================================================================================#

# how many events are in bsum, qat, blog and odf
n_bsum=length(unique(bsum_tests$event_bs))
n_qat=length(unique(qat_tests$event_qat))

# check if there are EVENTS in qat that are not in bsum
events_not_in_bsum=setdiff(unique(qat_tests$event_qat),unique(bsum_tests$event_bs))
events_not_in_qat=setdiff(unique(bsum_tests$event_bs),unique(qat_tests$event_qat))

# print the message on the screen if there is difference in number of events
sink(file=report_file,append=TRUE, split=TRUE)
if (length(events_not_in_qat)>0 | length(events_not_in_bsum)>0) {
  issues=issues+1
  cat("\n","\n")
  cat(paste("-> Cross Check CTD data only: Issue", issues, "- Events in QAT and BiolSum file are not the same"))
  cat("\n","\n")
  cat(paste("-> Number of CTD only events in QAT file:", n_qat))
  cat("\n","\n")
  cat(paste("-> Number of CTD only events in BiolSum file:", n_bsum))
  cat("\n","\n")
  
  if (length(events_not_in_bsum)>0){
    cat(paste("->", length(events_not_in_bsum), " CTD Events not in BiolSum:"))
    cat("\n","\n")
    print(qat_tests[which(qat_tests$event_qat %in% events_not_in_bsum),],row.names = FALSE)
  }
  
  if (length(events_not_in_qat)>0) {
    cat("\n","\n")
    cat(paste(length(events_not_in_qat)," CTD Events not in QAT file:"))
    cat("\n","\n")
    print(bsum_tests[which(bsum_tests$event_bs %in% events_not_in_qat),1:10],row.names = FALSE)
  }
  
} else { 
  cat("\n","\n")
  cat("-> Cross Check CTD data only: Events in QAT and BiolSum are the same.")}
sink()


# decide to proceed with merging or not

if (issues>0 | issue_files>0) {
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat("-> Cannot proceed. Please investigate reported issues.")
  sink()
  stop()
} 

sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")
cat("-> No issues detected so far. Continue with file merging...")
sink()


# ======================================================================#
#  MERGING: Bridge Log, BiolSums, QAT, and ODF headers for CTD data only
# ======================================================================#

# test events have to be merged differently because the id's could be repeating for different casts (1,2,3 etc)
# merge bsum and qat based on event and Sample ID
bsum_qat_tests=merge(qat_tests,bsum_tests, by.x=c("event_qat","id_qat"), by.y=c("event_bs","id_bs"), all.x=TRUE, all.y=FALSE)

# merge bsum_qat with odf headers based on event
bsum_qat_odf_tests=merge(bsum_qat_tests,odf_header, by.x="event_qat" ,by.y="Event_Number_odf", all.x=TRUE)

# merge with bridge log based on event
final_tests=merge(blog_header,bsum_qat_odf_tests, by.x="event_bl", by.y="event_qat", all.y=TRUE)

# replace NA in BiolSum depth with QAT pressure with 1 decimal place
na_depth=which(is.na(final_tests$depth_bs))
if (length(na_depth)>0) {
final_tests$depth_bs[na_depth]=round(final_tests$pressure_qat[na_depth],digits=1)
}

# replace 999999 sample ID in BiolSum with ID from QAT
final_tests$id_bs=final_tests$id_qat

# add start date_time columns
final_tests$event_sdate_stime=final_tests$start_date_time_odf # start date_time from ODF header
final_tests$event_edate_etime=final_tests$last_bottle_datetime_qat

final_tests$event_qat=final_tests$event_bl

final_tests=unique(final_tests)  # remove all repeated rows

# ====================================================================#
#  MERGING: Bridge Log, BiolSums, QAT, and ODF headers for bottle data
# ====================================================================#

# now I have dataframes to merge:
# blog_header, bsum_header, odf_header, qat_header

# merge bsum and qat based on Sample ID
bsum_qat=merge(bsum_header,qat_header, by.x="id_bs", by.y="id_qat", all=TRUE)

# check if the events match
ce=length(which(abs(bsum_qat$event_bs-bsum_qat$event_qat) >0))

# if there is discrepancies print the message
if (ce>0) {
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste(ce,"Different Events in QAT and BiolSums for the same Sample ID"))
  cat("\n","\n")
  print(bsum_qat[which(abs(bsum_qat$event_bs-bsum_qat$event_qat) >0),])
  sink()
}

# merge bsum_qat with odf headers based on event
bsum_qat_odf=merge(bsum_qat,odf_header, by.x="event_bs" ,by.y="Event_Number_odf", all=TRUE)

# merge with bridge log based on event
final=merge(blog_header,bsum_qat_odf, by.x="event_bl", by.y="event_bs", all=TRUE)
# done with merging. Merged file is called "final"

# -----------------------------------------------------------------------------#
# make start and end time columns: composite of bridge log, QAT and odf headers
# -----------------------------------------------------------------------------#

# start and end date_time are from bridge log 
final$event_sdate_stime=final$sdate_time_bl
final$event_edate_etime=final$edate_time_bl

# for CTD casts start date_time is from ODF headers 
ctd=which(!is.na(final$event_qat)) # find ctd casts only

final$event_sdate_stime[ctd]=final$start_date_time_odf[ctd] # start date_time from ODF header
final$event_edate_etime[ctd]=final$last_bottle_datetime_qat[ctd]

# AS IT IS NOW, THE EVENT_STIME COMES FROM CTD METADATA


# ---------------------------- #
# CHECK FOR SUSPECT SAMPLE IDs
# ---------------------------- #

# check if there are sample ID's with less than 6 digits
suspect_id_ind=which(nchar(final$id_bs)!=6 & !is.na(final$id_bs))

sink(file=report_file,append=TRUE, split=TRUE)
if (length(suspect_id_ind)>0){
  cat(c("\n","\n"))
  cat("-> Suspect Sample IDs found:")
  cat(c("\n","\n"))
  print(bsum[suspect_id_ind,])
  o=readline("Would you like to remove suspect samples? (y or n):")
  if (o=="y") { final=final[-suspect_id_ind,] }
  cat(c("\n","\n"))
  cat("-> Suspect Sample IDs removed.")
}
sink()

finalB=final # to keep a copy of final for bottles

############################################
# subset final to contain only CTD events  
final_bottles=final[which(!is.na(final$id_bs)),]
############################################
# this is done here and not at the bridgelog level because
# not all bridgelogs have a column indicating that a record is a ctd

# re-order the columns in tests datframe
final_tests=final_tests[,names(final_bottles)]

# stack together test casts and regular bottle casts
final=rbind(final_tests,final_bottles)



#         START QC FOR METADATA           #
# ========================================#
# PLOT THE DATA TO CHECK FOR DISCREPANCIES
# ========================================#

par(mfrow=c(1,1), mar=c(5.1,4.1,4.1,2.1)) # make sure to have 1 plot per image

# Make columns for time and location flags and set them to 1 (correct value)
final$position_qc_code=1
final$time_qc_code=1

#-------------------------------------------#
# check LATITUDE in qat file and bridge log
#-------------------------------------------#

latDif= final$lat_qat-final$slat_bl
ld=which(abs(latDif)>0.03) # flag latitudes that are different by 0.03 deg (about 3km) or more

# ---> DECIDE WHICH FLAG TO ASSIGN FOR POSITION <-----
final$position_qc_code[ld]=2  #assign flag

plot_title=paste("Latitude check: QAT file vs. Bridge Log","\n",qat_header$cruise_qat[1])
  
plot(final$event_bl,latDif, xlab="Event Number", ylab="QAT Lat  -  Bridge Lat   [deg]", 
     main=plot_title, col="blue")
points(final$event_bl[ld],latDif[ld],pch=19,col="red")
abline(0,0)

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_lat_check_QAT_BL.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()


sink(file=report_file,append=TRUE, split=TRUE)
if (length(ld)>0) {
  cat("\n","\n")
  cat("-> Latitude difference between bridge log and QAT > 0.03 deg:")
  cat("\n","\n")
  print(final[ld,c("event_bl","station_bl","sdate_time_bl","date_time_qat","slat_bl","lat_qat","slon_bl","lon_qat")])
}
sink()



# ------------------------------------------#
# check LONGITUDE in qat file and bridge log
# ------------------------------------------#
lonDif=final$lon_qat-final$slon_bl
ld=which(abs(lonDif)>0.03) # flag latitudes that are different by 0.03 deg (about 3km) or more

# ---> DECIDE WHICH FLAG TO ASSIGN FOR POSITION <-----
final$position_qc_code[ld]=2  #assign flag

plot_title=paste("Longitude check: QAT file vs. Bridge Log","\n",qat_header$cruise_qat[1])

plot(final$event_bl,lonDif, xlab="Event Number", ylab="QAT Lon  -  Bridge Lon   [deg]", 
     main=plot_title, col="blue")
points(final$event_bl[ld],lonDif[ld],pch=19,col="red")
abline(0,0)

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_lon_check_QAT_BL.png"))

dev.copy(png,fn,width=700,height=600, res=90)
dev.off()

sink(file=report_file,append=TRUE, split=TRUE)
if (length(ld)>0) {
  cat("\n","\n")
  cat("-> Longitude difference between bridge log and QAT > 0.03 deg:")
  cat("\n","\n")
  print(final[ld, c("event_bl","station_bl","sdate_time_bl","date_time_qat","slat_bl","lat_qat","slon_bl","lon_qat")])
  
}

sink()


# --------------------------------------------------------------------#
# check TIME (date and time together): QAT vs. ODF event start headers
# --------------------------------------------------------------------#
timeDif1=difftime(final$start_date_time_odf,final$date_time_qat, units="mins")
plot_title=paste("CTD Date_Time check: ODF start time vs. QAT time","\n",qat_header$cruise_qat[1])

plot(final$event_bl,timeDif1, xlab="Event Number", ylab="ODF start time  -  QAT Time  [minutes]", 
     main=plot_title, col="blue")
abline(0,0)

fn=file.path(outpath,paste0(mission,"_time_check_QAT_ODF.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()

# --------------------------------------------------------------------#
# check TIME (date and time together): Bridge log vs. ODF event start
# --------------------------------------------------------------------#
timeDif2=difftime(final$start_date_time_odf,final$sdate_time_bl, units="mins")
ld=which(abs(timeDif2)>20) # time difference greater than 20 min


if (all(is.na(timeDif2))) {
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat("-> Cannot compute difference between ODF time and Bridge log. All elements are NA.")
  cat("\n","\n")
  sink()
} else {

# ---> DECIDE HOW TO ASSIGN FLAGS FOR TIME <-----
final$time_qc_code[ld]=2  #assign flag

plot_title=paste("CTD DateTime check: ODF start time vs. Bridge start time","\n",qat_header$cruise_qat[1])

plot(final$event_bl,timeDif2, xlab="Event Number", ylab="ODF start time  -  BridgeLog start time  [minutes]", 
     main=plot_title, col="blue")
abline(0,0)
points(final$event_bl[ld],timeDif2[ld],pch=19,col="red")

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_time_check_ODF_BL.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()


sink(file=report_file,append=TRUE, split=TRUE)
if (length(ld)>0) {  
  cat("\n","\n")
  cat("-> Time difference between bridge log and ODF start time > 20 min:")
  cat("\n","\n")
  print(final[ld,c("event_bl","station_bl","sdate_time_bl","start_date_time_odf","slat_bl","Initial_Latitude_odf","slon_bl","Initial_Longitude_odf")] )
}
sink()
}

# -----------------------------------------------------#
# check DEPTH from BiolSums and Pressure from QAT file
# -----------------------------------------------------#

# difference between BiolSums Depth and pressure in qat file
depthDif=final$depth_bs - final$pressure_qat
plot_title=paste("Depth check: BiolSum Depth vs. QAT pressure","\n",qat_header$cruise_qat[1])


# identify depth difference of more than 5m or 3%
depth_lim=pmax(5,final$depth_bs*0.03, na.rm=TRUE)
dd5=which(abs(depthDif) > depth_lim)


# ----write comments on the screen and to the file----
sink(file=report_file,append=TRUE, split=TRUE)
# print info for the casts exceeding limits
if (length(dd5)>0) {
  cat("\n","\n")
  cat("-> DEPTH CHECK: BiolSum depth and QAT presure difference >5m or >3% for following casts:")
  cat("\n","\n")
  print(final[dd5, c("event_bl","event_qat","station_bl","id_bs","ctd_bs","depth_bs","pressure_qat")])   
} else {
  cat("\n","\n")
  cat("-> DEPTH CHECK: BiolSum depth and QAT pressure difference <5m or <3%.")
}
sink()
# --- done with coments ---


plot(final$event_bl,depthDif, xlab="Event Number", ylab="BiolSum depth  -  QAT Pressure  [m]", 
     main=plot_title, col="blue")
points(final$event_bl[dd5],depthDif[dd5], pch=19, col="red")
abline(0,0)

#legend("bottomleft",legend=c(paste0("difference > ",depth_lim,"m")),col=c("red"),
#       pch=c(NA,19),bty="n")

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_depth_check.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()

# plot depth difference as a function of BIOLsUMS depth
plot(final$depth_bs,depthDif, xlab="BiolSum depth [m]", ylab="BiolSum depth  -  QAT Pressure  [m]", 
     main=plot_title,col="blue")
points(final$depth_bs[dd5],depthDif[dd5], pch=19, col="red")
abline(0,0)
#legend("bottomleft",legend=c(mission,paste0("difference > ",depth_lim,"m")),col=c(NA,"red"),
#       pch=c(NA,19),bty="n")

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_depth_check1.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()


# ------------------------------------------------#
# check SOUNDING: Bridge Log vs. GEBCO bathymetry
# ------------------------------------------------#

final$sounding_bl=as.numeric(final$sounding_bl) #sometimes the sounding is character

# replace -99.9 or sounding < 10 with NA in ODF sounding
final$Sounding_odf[which(final$Sounding_odf < 20)]=NA
#soundingDif= final$sounding_bl - final$Sounding_odf

# check sounding vs. GEBCO bathymetry: get depth range in 0.1 deg box around station location
# use gebco_depth_range.r custom made function and bridge log position
dr=gebco_depth_range(final$slat_bl,final$slon_bl)

# merge bathymetry range with final data
sound=merge(final[,c("ctd_bs","event_bl", "station_bl","slat_bl","slon_bl","Sounding_odf","sounding_bl")],dr, by.x=c("slat_bl","slon_bl"), by.y=c("slat","slon"))

# look at CTD casts only
sound=unique(sound[!is.na(sound$ctd_bs),])


# if there is bridge log sounding then check versud GEBCO depths
if(!all(is.na(final$sounding_bl))) {


# write out the casts that are out of range
outs=which(sound$sounding_bl< sound$min_gebco | sound$sounding_bl> sound$max_gebco)

sink(file=report_file,append=TRUE, split=TRUE)
if (length(outs)>0) {
  cat("\n","\n")
  cat("-> Warrning: Bridge Log Sounding out of GEBCO range (0.1deg around location):")
  cat("\n","\n")
  print(sound[outs,])
} else {
  cat("-> All Bridge Log Sounding within GEBCO range in 0.1deg box around location.")
}
sink()

plot_title=paste("Sounding check: Bridge Log vs. ODF header","\n",qat_header$cruise_qat[1])

#plot sounding difference as a function of depth
# plot(final$sounding_bl,soundingDif, xlab="Sounding from Bridge Log", ylab="Bridge Log  -  ODF header  [m]", 
#      main=plot_title,col="blue")
# points(final$sounding_bl[outs],soundingDif[outs],pch=19, col="red")
# dev.copy(png,paste0(mission,"_sounding_check_4depth.png"), width=700,height=600, res=90)
# dev.off()

} else {
  cat("\n","\n")
  cat("-> Sounding Check not completed: No sounding data in the Bridge Log.")
}

#-----------------------------------#
# Check if the stations are on land
#-----------------------------------#

# indices of the stations on land
iland=which(sound$gebco_sounding<0)


sink(file=report_file,append=TRUE, split=TRUE)
if (length(iland)>0) {
  cat("\n","\n")
  cat("-> Warrning: Station might be on land:")
  cat("\n","\n")
  print(sound[iland,])
} else {
  cat("\n","\n")
  cat("-> No stations on land.")
}
sink()


# =============================================#
# check STATION NAMES: BiolSums and Bridge Log
# =============================================#

# rename biolsum stations
final$station_bs_renamed=rename_stations(final$station_bs)
final$station_bl_renamed=rename_stations(final$station_bl)

# take bottle casts (those are in biolsum and not in bridge log)
stn=which(final$station_bs_renamed != final$station_bl_renamed)

#Display list of stations with different name

if (length(stn)>0) {
sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")
cat("Stations with different names: Bridge Log and BiolSums:")
cat("\n","\n")
print(final[stn,c("station_bl","station_bs","station_bl_renamed","station_bs_renamed")])
sink()

} else {
sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")
cat("Station Name Check: Station Names in Bridge Log and BiolSum are the same.") 
sink()
}

#=== PART 2 ====
# ask if you want to rename bridge log stations
stt=final[,c("station_bl","station_bl_renamed")]
stt1=unique(stt)

sink(file=report_file,append=TRUE, split=TRUE)
# print on the screen original stationnames from bridge log and renamed stations
cat("\n","\n")
cat("-> Please check the original station names from bridge log:")
cat("\n","\n")
print(stt1)

op=readline("Would you like to rename the stations as per above? (y or n):")

if (op=="n") {
  final$station_bl_renamed=final$station_bl
  cat("\n","\n")
  cat("-> Original station names from Bridge Log retained.")
  cat("\n","\n")
}

sink()

# --- check if EVENT start and end times are missing ---

missing_stime=which(is.na(final$event_sdate_stime))
missing_etime=which(is.na(final$event_edate_etime))


sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")


if (length(missing_stime)>0) {
  no_stime_events=unique(final$event_bl[missing_stime])
  cat("-> WARNING: Event START time missing for following events:")
  cat("\n","\n")
  print(paste(no_stime_events, collapse=", "))
  cat("\n","\n")
}else{
  cat("-> All events have START time.")
  cat("\n","\n")
}

if (length(missing_etime)>0) {
  no_etime_events=unique(final$event_bl[missing_etime])
  cat("-> WARNING: Event END time missing for following events:")
  cat("\n","\n")
  print(paste(no_etime_events, collapse=", "))
}else{
  cat("-> All events have END time.")
  cat("\n")
}

sink()



#--- CHECK IF THE EVENT START IS BEFOR EVENT END ---

# difference between event end time and start tme
td=final$event_edate_etime-final$event_sdate_stime
problem=which(td<0)

sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")

if (length(problem)==0) {
  cat("-> Final time check : Event start time is before end time.")
  cat("\n","\n")
}else{
  cat("-> WARNING: Event start time is after end end time for following events:") 
  cat("\n","\n")
  print(final[problem, c("event_bl","event_sdate_stime","event_edate_etime")])
  cat("\n","\n")
}

sink()

# done with checks

# =============================== #
# GET MISSION INFO FOR THE HEADER #
# =============================== #

# get mission info from osccriose database. mission is cruise name, for example HUD2003067

mission1=mission

# make exception for the last century cruises: they don't have vessel ID in the cruise name in the osc cruise database
# for example HUD99003 is 99003 and HUD99054 is 99054
last_century=c("HUD99003","HUD99054") # have to add more cruises if you find them
if (mission %in% last_century) {
  mission1=substr(mission,4,nchar(mission))
}


osc=mission_info(mission1)


osc_info=osc[,!names(osc) %in% c("MISSION_DESCRIPTOR","LEG")] # remove MISSION_DESCRIPTOR and LEG column
osc_info$MISSION_GEOGRAPHIC_REGION=gsub("," , "-" ,osc_info$MISSION_GEOGRAPHIC_REGION) # replace any commas with semi-column
tosc=t(osc_info) # transposed osc info table

# columns in ODF ile for the header
odfc=c("Cruise_Number","Platform","Start_Date","End_Date","Organization","Chief_Scientist","Cruise_Name","Cruise_Description")

odf_info=odf_info[1,odfc]
todf=t(odf_info) #transposed odf info table

# have the same titles for the columns
names(odf_info)=names(osc_info)

# compare start and end date
sdd=difftime(as.Date(osc_info$MISSION_SDATE),as.Date(format_date(odf_info$MISSION_SDATE),"%d-%b-%Y"))
edd=difftime(as.Date(osc_info$MISSION_EDATE),as.Date(format_date(odf_info$MISSION_EDATE),"%d-%b-%Y"))

sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")
cat("-> Mission information from osccruise database:")
cat("\n","\n")
print(tosc)
cat("\n","\n")
cat("-> Mission information from ODF metadata:")
cat("\n","\n")
print(todf)

if (abs(sdd) >0) {
  cat("\n","\n")
  sm=paste("-> Warrning:", abs(sdd), "days difference in MISSION START DATE. Check cruise report for correct dates.")
  cat(sm)
  }

if (abs(edd) >0) {
  cat("\n","\n")
  sm=paste("-> Warrning:",abs(edd), "days difference in MISSION END DATE. Check cruise report for correct dates.")
  cat(sm)
}

sink()

# --------------------------------------------------#
# check if the dates are within cruise start and end
#---------------------------------------------------#


make_header=readline("Would you like to create BCS HEADER file? (y or n):")

if (make_header=="y") {

  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste("Creating BCS Header: file created for", mission))
  cat("\n","\n")
  sink()
  
  # nominal depth for CTD data only is QAT pressure
  ctd_only=which(final$GEAR_SEQ_bs==90000065)
  final$depth=final$depth_bs
  final$depth[ctd_only]=round(final$pressure_qat[ctd_only])
  
  
  
  
# ====================#
# CREATE HEADER FILE 
# ====================#

# one option is to type unknown fields on the screen
# protocol=readline("Input MISSION_PROTOCOL (exmple AZMP or AZOMP):")
# header_collector=readline("Input HEADER_COLLECTOR in charge of bottle samples (example AZMP-JEFF SPRY):")
# responsible_group=readline=("Input RESPONSIBLE_GROUP (example AZMP or AZOMP):")
# created_by=readline("Input your first and last name (person processing the data):") # can be turned on for input
created_by="Gordana Lazin" # hard coded for now
# the other option is to read the data from the "files" (excel file with cruise info)
protocol=files$mission_protocol
header_collector=files$header_collector
responsible_group=files$responsible_group
institute="DFO BIO" #institute is hard coded but can be changed in the script

header=NULL

header$MISSION_DESCRIPTOR=osc$MISSION_DESCRIPTOR 
header$EVENT_COLLECTOR_EVENT_ID=sprintf('%03d',final$event_bl)   # event from BRIDGE LOG,convert to string and add leading zeroes
header$EVENT_COLLECTOR_STN_NAME=final$station_bl_renamed         # station from bridge log

header$MISSION_NAME=osc_info$MISSION_NAME                        # mission name from OSCCRUISE database
header$MISSION_LEADER=osc_info$MISSION_LEADER                    # mission leader from OSCCRUISE database
header$MISSION_SDATE=format_date(osc_info$MISSION_SDATE)         # mission start date from OSCCRUISE database
header$MISSION_EDATE=format_date(osc_info$MISSION_EDATE)         # mission end date from OSCCRUISE database
header$MISSION_INSTITUTE=institute                               # mission institute is BIO (hardcoded)
header$MISSION_PLATFORM=osc_info$MISSION_PLATFORM                # mission platform from OSCCRUISE database
header$MISSION_PROTOCOL= protocol                                # mission protocol from Files_for_DIS_header.csv file
header$MISSION_GEOGRAPHIC_REGION=osc_info$MISSION_GEOGRAPHIC_REGION # mission geographic region from OSCCRUISE database
header$MISSION_COLLECTOR_COMMENT1=osc_info$COMMENTS              # comments if cruise has more than 1 leg, otherwise empty
header$MISSION_COLLECTOR_COMMENT2=""                             # empty
header$MISSION_DATA_MANAGER_COMMENT="Maritimes BioChem Reload"   # hardcoded

#header$EVENT_SDATE=format(final$sdate_time_bl,"%d-%b-%Y")        # start date from BRIDGE LOG
header$EVENT_SDATE=format(final$event_sdate_stime,"%d-%b-%Y")    # start date from CTD metadata
header$EVENT_EDATE=format(final$event_edate_etime,"%d-%b-%Y")    # last bottle from QAT file for CTD
header$EVENT_STIME=bctime(final$event_sdate_stime)               # start time from CTD metadata in HHMM FORMAT
header$EVENT_ETIME=bctime(final$event_edate_etime)               # last bottle time from QAT file for CTD IN HHMM format
header$EVENT_MIN_LAT=round(pmin(final$slat_bl,final$lat_qat, na.rm=T), digits=6)  # min start lat from BRIDGE LOG and last bottle QAT file lat
header$EVENT_MAX_LAT=round(pmax(final$slat_bl,final$lat_qat, na.rm=T), digits=6)  # max start lat from BRIDGE LOG and last bottle QAT file lat
header$EVENT_MIN_LON=round(pmin(final$slon_bl,final$lon_qat, na.rm=T), digits=6)  # min start lon from BRIDGE LOG and last bottle QAT file lon
header$EVENT_MAX_LON=round(pmax(final$slon_bl,final$lon_qat, na.rm=T), digits=6)  # max start lon from BRIDGE LOG and last bottle QAT file lon
header$EVENT_UTC_OFFSET=0                                        # UTC offset is always ZERO (BioChem convention)
header$EVENT_COLLECTOR_COMMENT1=final$comments_bl                # comments from BRIDGE LOG
header$EVENT_COLLECTOR_COMMENT2= ""                              # empty
header$EVENT_DATA_MANAGER_COMMENT= ""                            # empty

header$DIS_HEADR_GEAR_SEQ=final$GEAR_SEQ_bs                      # assigned in check_biolsum1, for bottle data 90000019, ctd only 90000065
header$DIS_HEADR_SDATE=format(final$date_time_qat,"%d-%b-%Y")    # date from QAT file 
header$DIS_HEADR_EDATE= header$DIS_HEADR_SDATE                   # end date is same as start date (from QAT file)
header$DIS_HEADR_STIME=bctime(final$date_time_qat)               # time from QAT file (each bottle has different time)
header$DIS_HEADR_ETIME=header$DIS_HEADR_STIME                    # end time is same as start time (from QAT file)
header$DIS_HEADR_TIME_QC_CODE=0                                  # 0 means no quality control !!!! TO BE DECIDED- WHEN TO ASSIGN FLAGS???
header$DIS_HEADR_SLAT=round(final$lat_qat, digits=6)                              # lat from QAT file
header$DIS_HEADR_ELAT=round(header$DIS_HEADR_SLAT, digits=6)                      # end lat same as start lat (from QAT file)
header$DIS_HEADR_SLON=round(final$lon_qat, digits=6)                              # lon from QAT file
header$DIS_HEADR_ELON=round(header$DIS_HEADR_SLON, digits=6)                      # end lon same as start lon (from QAT file)
header$DIS_HEADR_POSITION_QC_CODE=0                              # !!!! TO BE DECIDED- WHEN TO ASSIGN FLAGS???
header$DIS_HEADR_START_DEPTH=final$depth                      # Bottle depth from BiolSum for bottle and CTD or QAT pressure for CTD data only
header$DIS_HEADR_END_DEPTH=header$DIS_HEADR_START_DEPTH          # end bottle depth same as start bottle depth (from BiolSum)
header$DIS_HEADR_SOUNDING=final$sounding_bl                      # Sounding from BRIDGE LOG
header$DIS_HEADR_COLLECTOR_DEPLMT_ID= ""                         # empty
header$DIS_HEADR_COLLECTOR_SAMPLE_ID=final$id_bs              # Sample ID from BiolSum
header$DIS_HEADR_COLLECTOR=header_collector                      # from Files_for_DIS_header.csv file
header$DIS_HEADR_COLLECTOR_COMMENT1=paste("End depth=Start depth. Start depth is nominal.",final$comment_bs)
header$DIS_HEADR_DATA_MANAGER_COMMENT=paste("BioChem reload.QC performed using modified IML protocols.CTD OXY not calibrated with Winkler.",final$dmcomment,DIS_HEADR_DATA_MANAGER_COMMENT)
header$DIS_HEADR_RESPONSIBLE_GROUP=responsible_group             # from Files_for_DIS_header.csv file
header$DIS_HEADR_SHARED_DATA=""                                  # empty
header$CREATED_BY=created_by                                     # INPUT BY USER
header$CREATED_DATE=format(now(),"%d-%b-%Y")                     # system date when header is created
header$DATA_CENTER_CODE=20                                       # hard coded, 20 means BIO
header$PROCESS_FLAG="NR"                                         # hard coded
header$BATCH_SEQ=as.numeric(gsub("[[:alpha:]]","",mission))                                              # empty, will be assign when loaded



  

# next construct DIS_SAMPLE_KEY_VALUE
id=header$DIS_HEADR_COLLECTOR_SAMPLE_ID       # constructed using mission, event and sample ID
id[which(is.na(id))]="0"
DIS_SAMPLE_KEY_VALUE=paste0(header$MISSION_NAME,"_",header$EVENT_COLLECTOR_EVENT_ID,"_",id)

# header is a list. convert list to data frame
h=data.frame(header, stringsAsFactors=FALSE)

# add DIS_SAMPLE_KEY_VALUE to the first column
h=cbind(DIS_SAMPLE_KEY_VALUE,h)

# replace comments if the samples are CTD only (no bottle data)
ictd_only=which(h$DIS_HEADR_GEAR_SEQ == 90000065)
h$DIS_HEADR_COLLECTOR_COMMENT1[ictd_only]=paste("End depth=Start depth. Start depth is pressure from CTD QAT file.",final$comment_bs[ictd_only])  
h$DIS_HEADR_DATA_MANAGER_COMMENT[ictd_only]=paste("BioChem reload-QC performed using modified IML protocols. No bottle data.",DIS_HEADR_DATA_MANAGER_COMMENT)

# lat and lon should be 6 decimal places



# export to csv file
of=file.path(outpath,paste0(mission,"_BCS.csv"))
write.csv(h,of,row.names=FALSE,na="", quote=FALSE)
write.table(h,paste0(mission,"_BCS.txt"), sep="\t",na="")

}

# done with saving header file


# ========================================================= #
# PLOT CRUISE TRACK using leaflet and save it as html file
# ========================================================= #

# plots only cruise stations
#ct=cruisetrack_bcs(h)

# plots cruise stations and standard station locations
ct=cruisetrack_bcs_standard_stations(h)

# display cruise track in R window
ct

# save cruise trach as html
saveWidget(ct, file=file.path(outpath,paste0(mission,"_cruisetrack.html")))


# have to incorporate:
# rename_stations: to add underscore. Have to modufy so it works only for core stations
# Station_Name_Lookup -- benoit's script to check name from location
# write table to ptran

t1=now()
blog_original=read.xlsx(Bridge_log, stringsAsFactors=FALSE, sheetName ="BRIDGELOG_FOR_RELOAD")
#bsum_original=read.xlsx(BiolSum, stringsAsFactors=FALSE, sheetName ="BIOLSUMS_FOR_RELOAD")
t2=now()
t2-t1

