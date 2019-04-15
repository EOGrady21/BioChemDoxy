# script for checking and comparing cruises

require("RODBC")
require(xlsx)
require(tidyr)
require(readxl)
require(lubridate)
require(reshape)
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
source("check_bridgeLog_comp.r")
source("check_qat1.r")
source("check_ctd_metadata.r")
source("clr.r")
source("mkdirs.r")
source("mission_info.r")
source("is.installed.r")
source("correct_oxy.r")
source("find_outliers.r")
source("axis_range.r")
source("compare_sensors.r")
source("get_dataseq.r")
source("choose_qat_sensors.r")
source("check_qat_ranges.r")
source("stack_bcdata.r")
source("get_hplc.r")
source("find_strings_in_data.r")
source("na.columns.r")
source("get_precision.r")

# all the AZMP cruises
cruises=c("HUD99054","HUD2000050","HUD2001061","HUD2002064","HUD2003067","HUD2003078","HUD2004055",
          "HUD2005055", "HUD2006052","HUD2007045", "HUD2008037","HUD2009048", "HUD2010049","HUD2011043",
          "HUD2012042", "HUD99003","PAR2000002","HUD2001009","HUD2003005","HUD2004009","NED2005004",
          "HUD2006008","HUD2007001","HUD2008004","HUD2009005","HUD2010006","HUD2011004")


 

# pick one mision
mission=cruises[2]


# define file names based on the mision

fp="//dcnsbiona01a/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise/Files_for_DIS_header.csv"
files=read.csv(fp, stringsAsFactors=FALSE)

# select files for this particular mission
files=files[files$mission==mission,]

Bridge_log=file.path(files$path,files$Bridge_log)
BiolSum=file.path(files$path,files$BiolSum)
qatFile=file.path(files$path,files$qatFile)
odfFile=file.path(files$path,files$odf)
hplcFile=file.path(files$path,files$hplc)
chnFile=file.path(files$path,files$chn)

# ===========================================#
# CHECK DATA
# 1. load BIOLsUM FOR THE CRUISE
#============================================#

if (mission== "HUD2009005"){
  # this mission gets out of memeory error when reading excel file
  bsum=read.csv(BiolSum, stringsAsFactors=FALSE)
  bsum=bsum[,-grep("X",names(bsum))] #delete garbage columns
}else{
  
  # read BiolSum
  bsum=read.xlsx(BiolSum, stringsAsFactors=FALSE, sheetName ="BIOLSUMS_FOR_RELOAD")
}

bsum=clean_xls(bsum) # clean excel file

names(bsum)=gsub("Holm.Hansen","Holm-Hansen", names(bsum))


# 2. LOAD bcd and bcs FILE

bcdpath=file.path(getwd(),mission)
bcd_file=paste0(mission,"_BCD.csv")
bcs_file=paste0(mission,"_BCS.csv")

bcd=read.csv(file.path(bcdpath,bcd_file), stringsAsFactors=F)
bcs_f=read.csv(file.path(bcdpath,bcs_file))




# 3. Load DATA FROM STAGING TABLE, that was saved to csv files

# rename missions for 1999 cruises
if (mission %in% c("HUD99054","HUD99003")) {
  mission=gsub("[[:alpha:]]","",mission) # remove letters
}


# bcs_bc contains data from all missions
bcs_bc=read.csv("AZMP_BCS_BC.csv", stringsAsFactors=F)

# bcs contains data from particular mission
bcs=bcs_bc[which(bcs_bc$MISSION_NAME==mission),]

# mission descriptor
desc=unique(bcs$MISSION_DESCRIPTOR)

# bcd_bc contains data from all the missions
bcd_bc=read.csv("AZMP_BCD_BC.csv",stringsAsFactors=F)

# bcd contains biochem data from one particular mission
bcd=bcd_bc[which(bcd_bc$MISSION_DESCRIPTOR==desc),]


# # connect to database ptran
# # Create a database connection.
# con = odbcConnect( dsn="PTRAN", uid="lazing", pwd="Fdg8833p", believeNRows=F)
# 
# bcsq=paste0("select * from LAZING.AZMP_MISSIONS_BCS where MISSION_NAME = '",mission,"';" )
# 
# # run BCS query
# bcs_bc=sqlQuery(con,bcsq)
# 
# desc=unique(bcs_bc$MISSION_DESCRIPTOR)
# 
# # query bcd based on the mission descriptor
# bcdq=paste0("select * from LAZING.AZMP_MISSIONS_BCD where MISSION_DESCRIPTOR = '",desc,"';" )
# 
# # run BCD query
# bcd_bc=sqlQuery(con,bcdq)
# 

# 4. COMPARE: PLOT DATA VS SAMPLE ID?

# compare biolsum data

vars=c("Chl_a_Holm-Hansen_F","Phaeo_Holm-HansenF","o2_ml","NO2NO3_Tech_F","SiO4_Tech_F","PO4_Tech_F")
vars_bc=c("Chl_a_Holm-Hansen_F","Phaeo_Holm-HansenF","O2_Electrode_mll","NO2NO3_Tech_F","SiO4_Tech_F","PO4_Tech_F")

for (i in 1:length(vars)) {

ichl=which(bcd$DATA_TYPE_METHOD== vars_bc[i])

# biochem chlorophyll
bc_data=bcd[ichl, c("DIS_DETAIL_COLLECTOR_SAMP_ID","DIS_DETAIL_DATA_VALUE")]
names(bc_data)=c("id","bc_data")

# order by id
bc_data=bc_data[order(bc_data$id),]

# biolsum chlorophyll
bsum_data=bsum[,c("id",vars[i])]
names(bsum_data)=c("id","bsum_data")

bsum_data=bsum_data[which(!is.na(bsum_data$bsum_data)),]
bsum_data=bsum_data[order(bsum_data$id),]

# plot(bsum_data$id,bsum_data$bsum_data, xlab="Sample ID", ylab=vars[i], main=mission, col="blue")
# points(bc_data$id,bc_data$bc_data,pch=19, col="red", cex=0.4)

# order both data frames by sample ID
data=merge(bsum_data,bc_data,by="id", all.x=T)

# plot the difference
difference=data$bsum_data-data$bc_data
#plot(data$id,difference, xlab="Sample ID", ylab=paste(vars[i],"difference"),main=mission, col="blue")

hist(difference, main=paste(vars_bc[i],",",mission), col="dodgerblue", xlab="Difference between BioChem staging table and source data")
}

#  DONE COMPARING BIOLSUM DATA WITH BCD TABLE
# ============================================#

#=============================================#
#           CHECK EVENT_SDATE 

# Now compare metadata, Dates in ctd metadata
# EVENT_SDATE Biochem vs. CTD metadata



# load ctd metadata
odf_list=check_ctd_metadata_comp(odfFile)
odf=odf_list$odf_header

odf$date=as.Date(odf$start_date_time_odf)

# bcs is the data from biochem table
# compare odf datae with biochem start date

# merge bcs_bc biochem table with CTD metadata by event number
m=merge(bcs,odf,by.x="EVENT_COLLECTOR_EVENT_ID", by.y="Event_Number_odf", all.x=TRUE)

# compare the dates EVENT_SDATE and date 
m$EVENT_SDATE=as.Date(m$EVENT_SDATE)

setdiff(m$EVENT_SDATE,m$date)

a=which(m$EVENT_SDATE-m$date != 0)

if (length(a)=0) {
  cat("-> EVENT_SDATE in BC table equals to the date at CTD metadata source file.")
} else {
  cat("-> WARNING: EVENT_SDATE in BC table DIFFERS from the date at CTD metadata source file.")
}


#=================================================#
# CHECK DIS_HEADER_SDATE biochem vs. QAT date

# DIS_HEADER_SDATE biochem vs. QAT date


# Bridge_log is file name, and check_bridgeLog is a function for QC
blog=check_bridgeLog_comp(Bridge_log)

# events that match
iev=which(blog$event_bl %in% bcs$EVENT_COLLECTOR_EVENT_ID)

bcs_bc$EVENT_SDATE

blog$sdate_bl

# data frame containing events, station names and dates
bcs_ev=unique(bcs[,c("EVENT_COLLECTOR_EVENT_ID", "EVENT_COLLECTOR_STN_NAME", "EVENT_SDATE")])

blog_ev=blog[iev,c("event_bl","station_bl", "sdate_bl")]

mev=merge(blog_ev, bcs_ev, by.x="event_bl", by.y="EVENT_COLLECTOR_EVENT_ID")

mev$sdate_bl=as.Date(mev$sdate_bl,"%d-%b-%Y")

mev$EVENT_SDATE=as.Date(mev$EVENT_SDATE,"%Y-%m-%d")

datedif=mev$sdate_bl-mev$EVENT_SDATE

dd[with(dd, order(-z, b)), ]



