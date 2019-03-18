# plot AZOMP on the map
# create BCS file

source("cruisetrack_bcs_standard_stations_AZOMP.r")
source("is.installed.r")
require(leaflet)
require(reshape)
require(lubridate)
require(htmlwidgets)
require(xlsx) #loads xlsx package
source("mission_info.r")
source("osccruise.r")
source("na.rows.r")
source("format_date.r")
source("bctime.r")

source("rename_stations.r")
source("substrRight.r")


# working direstory
setwd("C:/Gordana/Biochem_reload/working")

# path to Lab Sea data that Inna made
#lspath="//dcnsbiona01a/BIODataSvc/SRC/BIOCHEMInventory/Inna/Lab_Sea/Discrete_Data"


# load the list of the cruises
cruises=read.csv("AZOMP_cruises.csv",stringsAsFactors=F)

# just the number of the cruises
cruise_number=substr(cruises$name,4,nchar(cruises$name))

azomp=NULL

# =====> START OF THE LOOP FOR MERGING ALL CRUISES <=====
# load all cruises and merge them to one file
for (i in 1:length(cruise_number)) {

cruise= cruise_number[i]

if (cruises$name[i]=="99022") {
  cruise="99022"
}

# construct file name for the data file
#fn=paste0("18HU",cruise_number[i],"_1_hy1.csv")
# file names are now on the list because they don't follow naming protocol

# file name with the path
fnp=file.path(cruises$path[i],cruises$hy1[i])

# read the data
df=read.csv(fnp,stringsAsFactors=F, skip=1)

# delete last row, it has NA for all the columns
df=df[-dim(df)[1],]

# add cruise descriptor and cruise name
df$descriptor=cruises$descriptor[i]
df$name=cruises$name[i]

#================#
# ADD DEPTH FILE: 
#================#

# construct file name: cruise number_depths.xls
depth_file=paste0(cruise,"_depths.xls")
depth_file=file.path(cruises$path[i],depth_file) # file name with path

# read the depths file
depths=read.xlsx(depth_file, stringsAsFactors=FALSE, sheetIndex=1)

# check if the depths has all the events
dcd=setdiff(unique(df$event), depths$Event_Number)

# if there is difference write a message and stop
if(length(dcd)>0) {
  cat("\n","\n")
  cat("-> Event numbers in hy1 file and depths files are not the same! Cannot continue. Please investigate")
  cat("\n","\n")
  stop()
}

# merge depths to hy1 data (df) by event number

df=merge(df,depths,by.x="event",by.y="Event_Number")


# add columns if they are missing
col2add=c("PAR","pH","NH3","MCHFRM","cfc11","cfc12","cfc113", "ccl4","SF6")

for (j in 1:length(col2add)) {

# add column "PAR" to each cruise if there is no par
if (length(grep(col2add[j],names(df)))==0){
  eval(parse(text=paste0("df$",col2add[j],"=NA")))
}
}



# add column "NO2" if it doesnt exist
if (length(which(names(df)=="NO2"))==0){
  df$NO2=NA
}




azomp=rbind(azomp,df)
} 

#========> END OF LOOP FOR MERGING ALLTHE CRUISES <============


# replace -999 with NA
azomp[azomp==-999]=NA

# ===========================================#
# count records for each cruise and variable
# ===========================================#

# find cruise and id columns
cid=which(names(azomp) %in% c("cruise"))

data=azomp[,c(cid,15:length(names(azomp)))]

# have to melt cross table first
ma=melt(data,id="cruise",na.rm=T) # does not remove NA unless specified

# make a table with counts for each variable and cruise
datacount=xtabs(~cruise+variable,ma)

# save the table
write.csv(datacount,"azomp_data_count.csv")

# stations for all cruises that can be used for plotting everything
# with "plot_all_azomp)stations.r"
us=unique(azomp[,c("station_name","lat_odf", "lon_odf","date_odf")])
write.csv(us,"all_azomp_stations.csv")

# ============================#
# PLOT EACH CRUISE ON THE MAP 
# ============================#

# have to rename the columns to use the BCD plotting function
# subset so you can use AZMP function
# pd=azomp[,c("cruise","station_name","date_odf","lat_odf","lon_odf","time_odf")]
# 
# names(pd)=c("cruise","EVENT_COLLECTOR_STN_NAME","EVENT_SDATE","EVENT_MIN_LAT","EVENT_MIN_LON","EVENT_STIME")
# 
# # plot all cruises in the loop
# 
#  for (i in 1:length(unique(pd$cruise))) {
# #   
#  mission=unique(pd$cruise)[i]
# # 
# # #data for one cruise
#  pdm=pd[which(pd$cruise==mission),]
# #   
#  ct1=cruisetrack_bcs_standard_stations_AZOMP(pdm)
# # 
# # 
#  saveWidget(ct1, file=paste0(mission,"_cruisetrack.html"))
# 
# }


#===============#
# MAKE BCS FILE # 
#===============#


# Get cruise info for all cruises from osccruise database
a=NULL
for (i in 1:length(cruises$name)) {
  b=mission_info(cruises$name[i])
  a=rbind(a,b)
}

# replace commas with "-"
a$MISSION_GEOGRAPHIC_REGION=gsub("," , "-" ,a$MISSION_GEOGRAPHIC_REGION) # replace any commas with semi-column

# merge azomp file with mission descriptor
final=merge(azomp,a, by.x="descriptor", by.y="MISSION_DESCRIPTOR",all.x=TRUE)

# Create gear sequence. If cast has any bottle data then the gear sequence is 90000019
final$GEAR_SEQ=90000019

# look which records do not have bottle data. make a vector with bottle data parameter names
bp=c("o2","SiO4_Tech_Fsh","PO4_Tech_Fsh","NO2NO3_Tech_Fsh","TIC","Alkalinity",
     "cfc11","cfc12","cfc113", "ccl4","MCHFRM","PAR","pH","NH3","SF6","NO2")

# data frame with bottle data only:
bottle_data=final[,which(names(final) %in% bp)]

# find which rows do not have any bottle data. For these rows the GEAR_SEQ is ctd only 90000065
final$GEAR_SEQ[na.rows(bottle_data)]=90000065

#===================================================================#
# get end of the event from the time of the last bottle in qat file
#===================================================================#

# make a column with Date and Time together in the date format with UTC time zone
# add leading zeroes to time
final$time_qat=sprintf("%04d",final$time_qat)

final$date_time_qat=strptime(paste(final$date_qat,final$time_qat), "%d-%b-%y %H%M", tz="GMT")
final$date_time_qat=as.POSIXct(final$date_time_qat) # change format from POSIXlt to POSIXct so you can use aggregate function later

# add column containing the date_time of the last botle in the event
# have to aggregate first and find the last bottle date_time for each event
eet=aggregate(date_time_qat ~ event+descriptor, data=final, max,na.rm=TRUE)
names(eet)=c("event","descriptor","last_bottle_datetime")
eet$last_bottle_datetime=as.POSIXlt(eet$last_bottle_datetime,"GMT") # change back to original date format


# add eet to qat by merging
final=merge(final,eet, by=c("event","descriptor"),all=TRUE)

# add maximum CTD depth for each event, same way as last bottle datetime
maxctd=aggregate(Pressure ~ event+descriptor, data=final, max,na.rm=TRUE)
names(maxctd)=c("event","descriptor","max_ctd_depth")

# add eet to qat by merging
final=merge(final,maxctd, by=c("event","descriptor"),all=TRUE)


#================#
# CHECK SOUNDING #
#================#
source("gebco_depth_range.r")
require(marmap)

# replace -99.9 or sounding < 10 with NA in ODF sounding: impossible value
final$Sounding[which(final$Sounding < 20)]=NA

# check sounding vs. GEBCO bathymetry: get depth range in 0.1 deg box around station location
# use gebco_depth_range.r custom made function and bridge log position
dr=gebco_depth_range(final$lat_odf,final$lon_odf)

# merge bathymetry range with final data
sound=merge(final[,c("name","date_odf", "event", "station_name","lat_odf","lon_odf","Sounding","max_ctd_depth")],dr, by.x=c("lat_odf","lon_odf"), by.y=c("slat","slon"))

plot(gebco_sounding~Sounding, data=sound, col="blue", main="AZOMP 1999-2012",xlab="BCS Sounding [m]",ylab="GEBCO sounding [m]")

if(!all(is.na(final$Sounding))) {
  
  
  # write out the casts that are out of range
  outs=which(sound$Sounding< sound$min_gebco | sound$Sounding> sound$max_gebco)
  
  if (length(outs)>0) {
    cat("\n","\n")
    cat("-> Warrning: Bridge Log Sounding out of GEBCO range (0.1deg around location):")
    cat("\n","\n")
    print(unique(sound[outs,]))
  } else {
    cat("-> All Bridge Log Sounding within GEBCO range in 0.1deg box around location.")
  }
}

out_sounding=unique(sound[outs,])
out_sounding$diff=out_sounding$Sounding-out_sounding$gebco_sounding
out_sounding$abs_diff=abs(out_sounding$diff)

write.csv(out_sounding,"lab_sea_soundingdifference.csv")





# ======================#
# CREATE BCS HEADER FILE 
# ======================#

# one option is to type unknown fields on the screen
# protocol=readline("Input MISSION_PROTOCOL (exmple AZMP or AZOMP):")
# header_collector=readline("Input HEADER_COLLECTOR in charge of bottle samples (example AZMP-JEFF SPRY):")
# responsible_group=readline=("Input RESPONSIBLE_GROUP (example AZMP or AZOMP):")
# created_by=readline("Input your first and last name (person processing the data):") # can be turned on for input
created_by="Gordana Lazin" # hard coded for now
# the other option is to read the data from the "files" (excel file with cruise info)
protocol="AZOMP"
header_collector="AZOMP - JEFF JACKSON"
responsible_group="AZOMP"
institute="DFO BIO" #institute is hard coded but can be changed in the script

header=NULL

header$MISSION_DESCRIPTOR=final$descriptor 
header$EVENT_COLLECTOR_EVENT_ID=sprintf('%03d',final$event)      # event from ODF FILES,convert to string and add leading zeroes
header$EVENT_COLLECTOR_STN_NAME=final$station_name               # station from hy1 file, originally in acess databasa

header$MISSION_NAME=final$MISSION_NAME                        # mission name from OSCCRUISE database
header$MISSION_LEADER=final$MISSION_LEADER                    # mission leader from OSCCRUISE database
header$MISSION_SDATE=format_date(final$MISSION_SDATE)         # mission start date from OSCCRUISE database
header$MISSION_EDATE=format_date(final$MISSION_EDATE)         # mission end date from OSCCRUISE database
header$MISSION_INSTITUTE=institute                               # mission institute is BIO (hardcoded)
header$MISSION_PLATFORM=final$MISSION_PLATFORM                # mission platform from OSCCRUISE database
header$MISSION_PROTOCOL= protocol                                # mission protocol from Files_for_DIS_header.csv file
header$MISSION_GEOGRAPHIC_REGION=final$MISSION_GEOGRAPHIC_REGION # mission geographic region from OSCCRUISE database
header$MISSION_COLLECTOR_COMMENT1=final$COMMENTS              # comments if cruise has more than 1 leg, otherwise empty
header$MISSION_COLLECTOR_COMMENT2=""                             # empty
header$MISSION_DATA_MANAGER_COMMENT="Maritimes BioChem Reload"   # hardcoded

header$EVENT_SDATE=format_date(as.Date(final$date_odf,"%d-%b-%y"))                                # start date from CTD metadata
header$EVENT_EDATE=format(final$last_bottle_datetime,"%d-%b-%Y")    # last bottle from QAT file for CTD
header$EVENT_STIME=sprintf('%04d',final$time_odf)                 # start time from CTD metadata in HHMM FORMAT
header$EVENT_ETIME=bctime(final$last_bottle_datetime)               # last bottle time from QAT file for CTD IN HHMM format
header$EVENT_MIN_LAT=round(final$lat_odf, digits=6)  # min start lat from BRIDGE LOG and last bottle QAT file lat
header$EVENT_MAX_LAT=round(final$lat_odf, digits=6)  # max start lat from BRIDGE LOG and last bottle QAT file lat
header$EVENT_MIN_LON=round(final$lon_odf, digits=6)  # min start lon from BRIDGE LOG and last bottle QAT file lon
header$EVENT_MAX_LON=round(final$lon_odf, digits=6)  # max start lon from BRIDGE LOG and last bottle QAT file lon
header$EVENT_UTC_OFFSET=0                                        # UTC offset is always ZERO (BioChem convention)
header$EVENT_COLLECTOR_COMMENT1=""                               # comments from BRIDGE LOG
header$EVENT_COLLECTOR_COMMENT2= ""                              # empty
header$EVENT_DATA_MANAGER_COMMENT= ""                            # empty

header$DIS_HEADR_GEAR_SEQ=final$GEAR_SEQ                         # assigned in check_biolsum1, for bottle data 90000019, ctd only 90000065
header$DIS_HEADR_SDATE=format(final$date_time_qat,"%d-%b-%Y")    # date from QAT file 
header$DIS_HEADR_EDATE= header$DIS_HEADR_SDATE                   # end date is same as start date (from QAT file)
header$DIS_HEADR_STIME=bctime(final$date_time_qat)               # time from QAT file (each bottle has different time)
header$DIS_HEADR_ETIME=header$DIS_HEADR_STIME                    # end time is same as start time (from QAT file)
header$DIS_HEADR_TIME_QC_CODE=0                                  # 0 means no quality control !!!! TO BE DECIDED- WHEN TO ASSIGN FLAGS???
header$DIS_HEADR_SLAT=round(final$lat_odf, digits=6)                              # lat from QAT file
header$DIS_HEADR_ELAT=round(header$DIS_HEADR_SLAT, digits=6)                      # end lat same as start lat (from QAT file)
header$DIS_HEADR_SLON=round(final$lon_odf, digits=6)                              # lon from QAT file
header$DIS_HEADR_ELON=round(header$DIS_HEADR_SLON, digits=6)                      # end lon same as start lon (from QAT file)
header$DIS_HEADR_POSITION_QC_CODE=0                              # !!!! TO BE DECIDED- WHEN TO ASSIGN FLAGS???
header$DIS_HEADR_START_DEPTH=round(final$Pressure, digits=2)                      # Bottle depth from BiolSum for bottle and CTD or QAT pressure for CTD data only
header$DIS_HEADR_END_DEPTH=header$DIS_HEADR_START_DEPTH          # end bottle depth same as start bottle depth (from BiolSum)
header$DIS_HEADR_SOUNDING=final$sounding                      # Sounding from BRIDGE LOG
header$DIS_HEADR_COLLECTOR_DEPLMT_ID= ""                         # empty
header$DIS_HEADR_COLLECTOR_SAMPLE_ID=final$id              # Sample ID from BiolSum
header$DIS_HEADR_COLLECTOR=header_collector                      # from Files_for_DIS_header.csv file
header$DIS_HEADR_COLLECTOR_COMMENT1="End depth=Start depth. Start depth is pressure from CTD QAT file."
header$DIS_HEADR_DATA_MANAGER_COMMENT="BioChem reload.QC performed using modified IML protocols.CTD OXY not calibrated with Winkler."
header$DIS_HEADR_RESPONSIBLE_GROUP=responsible_group             # from Files_for_DIS_header.csv file
header$DIS_HEADR_SHARED_DATA=""                                  # empty
header$CREATED_BY=created_by                                     # INPUT BY USER
header$CREATED_DATE=format(now(),"%d-%b-%Y")                     # system date when header is created
header$DATA_CENTER_CODE=20                                       # hard coded, 20 means BIO
header$PROCESS_FLAG="NR"                                         # hard coded
header$BATCH_SEQ=NA
#header$BATCH_SEQ=as.numeric(gsub("[[:alpha:]]","",mission))                                              # empty, will be assign when loaded





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
h$DIS_HEADR_COLLECTOR_COMMENT1[ictd_only]="End depth=Start depth. Start depth is pressure from CTD QAT file."  
h$DIS_HEADR_DATA_MANAGER_COMMENT[ictd_only]="BioChem reload-QC performed using modified IML protocols. CTD OXY not calibrated with Winkler. No bottle data."

# DIS_HEADER_COLLECTOR for station HL_02 hould be "AZMP - Jeff Spry" as the samples were frozen
hl2=which(h$EVENT_COLLECTOR_STN_NAME %in% "HL_02")
h$DIS_HEADR_COLLECTOR[hl2]="AZMP - JEFF SPRY"

# For all AZMP stations responsible group should be changed to AZMP
# read list of AZMP stations
azmpst=read.csv("AZMP_Stations_Definition_GL.csv", stringsAsFactors=F)
azmp_responsible=which(h$EVENT_COLLECTOR_STN_NAME %in% azmpst$bc.name)
h$DIS_HEADR_RESPONSIBLE_GROUP[azmp_responsible]="AZMP"

# export to csv file
of="AZOMP_MISSIONS_BCS.csv"
#write.csv(h,of,row.names=FALSE,na="", quote=FALSE)
#write.table(h,"AZOMP_MISSIONS_BCS.txt", sep="\t",na="")



# done with saving header file


