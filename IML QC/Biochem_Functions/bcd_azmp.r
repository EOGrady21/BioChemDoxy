# merge BuiChem historical data and create BCD table
# Gordana Lazin, BioChem Reboot project, 22-Apr-2016

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
source("check_bridgeLog.r")
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

mission="HUD2011043"


# ======================================================== #
# DEFINING WHICH DATA FILES TO READ -- has to be developed
# ======================================================== #
# read inventory created by Emily

wdpath='C:/Gordana/Biochem_reload/working'
setwd(wdpath)

# run get_filelist_4reboot.r to get approximate list of the files
# that list has to be manually checked and edited to make sure appropriate files are there
# once that this is done it can be ued for data loading

# this could be a file name
# fln="files_BC_reboot.csv"
# path1=path="//dcnsbiona01a/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise"
# fln=file.path(path,fln)
# 
# # read the file: has all the cruises and filenames.
# files=read.csv(fln)
# 
# # pick a mission and all associated files
# fm=files[which(fles$mission==mission),]


fp="//dcnsbiona01a/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise/Files_for_DIS_header.csv"
files=read.csv(fp, stringsAsFactors=FALSE)

# select files for this particular mission
files=files[files$mission==mission,]

Bridge_log=file.path(files$path,files$Bridge_log)
BiolSum=file.path(files$path,files$BiolSum)
qatFile=file.path(files$path,files$qatFile)
odfFile=file.path(files$path,files$odf)


# =========== #
#  HPLC DATA  #
# =========== #

# read HPLC data file -- this has to be ironed out
fn="Hud2011-043HPLC.xls" # fn=fm$hplc
path="//dcnsbiona01a/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise/2010+/2011/HUD2011043"
fnp=file.path(path,fn) # fnp=file.path(fm$path,fm$hplc)

# read excel file - make sure they are all in the he same format
hplc=read_excel(fnp,sheet="Pigments",skip=2)

# convert to regular data frame
hplc=as.data.frame(hplc)

# remove NA rows from the dataframe
if (length(na.rows(hplc))>0) {
hplc=hplc[-na.rows(hplc),]
}

hplc0=hplc

 # rename columns to BioChem names

# biochem METHOD for hplc data
bc_hplc=c("HPLC_ACAROT","HPLC_ALLOX","HPLC_ASTAX","HPLC_BCAROT","HPLC_BUT19","HPLC_BUTLIKE","HPLC_CHLA",
        "HPLC_CHLB","HPLC_CHLC12","HPLC_CHLC3","HPLC_CHLIDEA","HPLC_DIADINOX","HPLC_DIATOX","HPLC_FUCOX",
        "HPLC_HEX19","HPLC_HEXLIKE","HPLC_HEXLIKE2","HPLC_PERID","HPLC_PHAEO","HPLC_PRASINOX","HPLC_PYROPHAE",
        "HPLC_VIOLAX","HPLC_ZEA")

# pigment names without hplc_ in front
bch=gsub("HPLC_","",bc_hplc) # methods from biochem
fch=gsub("HPLC","",names(hplc),ignore.case=TRUE) # column names from data

# sometimes original files have PHAE incted of PHAEO, so that has to be replaced
if (length(which(fch=="PHAE"))>0) {
fch[which(fch=="PHAE")]="PHAEO"
}

# match pigment names in hplc file to the names from biochem

# find corresponding columns
ni=match(fch,bch)

# rename hplc clumns with names for BioChem
mn=which(!is.na(ni)) # matching names


hplc=hplc0 # just temporary line for testing

# replace names in hplc file with the biochem METHOD
names(hplc)[mn]=bc_hplc[ni[mn]]

# are all columns in hplc file matched?
nomatch=setdiff(names(hplc),names(hplc)[mn]) # difference between all names in HPLC file and matching names
not_pigments=c("ID","DEPTH")

# difference between pigments in HPLC file and the ones in BioChem
sd=setdiff(nomatch,not_pigments)

if (length(sd)==0) {
  cat("\n","\n")
  cat("All pigments in HPLC file matched to BioChem METHOD.")
  
}

if (length(sd)>0) {

cat("Pigments NOT matched to the HPLC methods in BioChem:",paste(sd,collapse=", "))
cat("\n","\n")
cat("You can continue without those fields or you can correct pigment spelling in the HPLC file.")
cat("\n","\n")
op=readline("Would you like to continue withot those fields (y or n)?:")

if (op=="y") {
  hplc=hplc[,-grep(sd,names(hplc))]
  cat("\n","\n")
  cat(paste("Fields removed from HPLC data:",paste(sd,collapse=", ")))
}

if (op=="n") {
  cat("\n","\n")
  cat("Please correct pigment spelling in the HPLC excel sheet.")
  stop()
}

}


# remove DEPTH column
dpth=grep("DEPTH",names(hplc))

if (length(dpth)>0){
  hplc=hplc[,-dpth] 
}

# rename ID to id
names(hplc)[grep("ID",names(hplc))]="id"

# stack the data
mhplc=stack_bcdata(hplc)


# ========== #
#  CHN DATA  #
# ========== #

# !!!!!WATCH: CHN HAS DUPLICATES!!!!#

cf="CHNSShelf2011-043.xls"
cp=file.path(path,cf)

chn=read_excel(cp,sheet="Results",skip=3)

# convert to proper data frame
chn=as.data.frame(chn)

# remove NA rows from the dataframe
if (length(na.rows(chn))>0) {
  chn=chn[-na.rows(chn),]
}

# RENAME CHN COLUMNS
chn_names=c("I.D.","VOLUME(L)","CARBON(micrograms)","NITROGEN(micrograms)","C/L(micrograms/litre)",
            "N/L(micrograms/litre)", "C/N")

chn_short=c("id","volume","c_um","n_um","poc","pon", "cn_ratio")


# compute avarage value from duplicates
chn_mean=aggregate(.~ I.D., mean, data = chn)

# duplicates will be loaded
# compute standard deviation of duplicates
chn_stdp=aggregate(.~ I.D., function(x){100*sd(x)/mean(x)}, data = chn)

# compute number of points (duplicates or triplicates?)
chn_n=aggregate(.~ I.D., length, data = chn)



# ======== #
# BiolSum
# ======== #

fp="//dcnsbiona01a/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise/Files_for_DIS_header.csv"
files=read.csv(fp, stringsAsFactors=FALSE)

# select files for this particular mission
files=files[files$mission==mission,]


BiolSum=file.path(files$path,files$BiolSum)
qatFile=file.path(files$path,files$qatFile)

# read BiolSum
bsum=read.xlsx(BiolSum, stringsAsFactors=FALSE, sheetName ="BIOLSUMS_FOR_RELOAD")
bsum=clean_xls(bsum) # clean excel file

# define columns with metadata
bsum_meta=c("ctd","depth","event","station","sdate","stime","slat","slon","doy","slat_deg","slat_min","slon_deg","slon_min")

# keep only data column
bsum=bsum[,!(names(bsum) %in% bsum_meta)]

# fix the header. excel reader reads - as . for some reason
names(bsum)=gsub("Holm.Hansen","Holm-Hansen",names(bsum))

# make stacked dataset with data type sequences using stack_bcdata function
mbs=stack_bcdata(bsum)



# ======== #
# QAT file
# ======== #

# read QAT file
qat=read.csv(qatFile,stringsAsFactors=FALSE, strip.white=TRUE)

# define columns with metadata
qat_meta=c("ctd_file","cruise","event","lat","lon","trip","date","time")

# keep only data column
qat=qat[,!(names(qat) %in% qat_meta)]

# visually compare sensors in qat file and save the plots
compare_sensors(qat,mission)
cat("\n","\n")
cat(" *********** PLEASE EXAMINE SENSOR COMPARISON PLOTS *********** ")
cat("\n","\n")

op=readline("Are you ready to continue (y or n)?: ")

if (op=="n") {
  
  stop()
}

# check ranges of qat data for temp, sal, oxy
check_qat_ranges(qat)

# choose primary or secondary sensors. 
# Output is list that contains a dataframe and name of original sensors.
ll=choose_qat_sensors(qat)

qf=ll$qf #qf is dataframe with qat data that has only one sensor for each parameter
original_sensors=ll$original_sensors # contains names with choices of original sensors


# =============== #
#  OXY correction
# =============== #

# introduce oxy_flag to track if oxy correction
# oxy_flag=0 no oxy correction was made to qat file
# oxy_flag=1 oxy correction is aplied to qat oxy using winkler
oxy_flag=0
 
# check if BiolSum has o2_winkler

wb=grep("winkler",names(bsum),ignore.case=TRUE)

# if winkler exsists proceede with correction

if (length(wb)>0) {
  
  
  #  merge biolsum and qat based on the sample ID
  bsq=merge(bsum,qf, by.x="id",by.y="id", all=TRUE)
  
  # find out which oxy sensor is in qat file. 
  # This works for qat file that has oxy1, oxy2 or just oxy
  oxs=names(qf)[grep("oxy",names(qf))] # name of the oxy sensor (oxy1 or oxy2 or oxy)
  oxy_sensor=gsub("[[:alpha:]]","",original_sensors[grep("oxy",original_sensors)]) # original oxy sensor
  
  # define winkler and ctd oxy vectors
  winkler=bsq[,grep("winkler",names(bsq),ignore.case=TRUE)]
  ctd_oxy=bsq[,grep("oxy",names(bsq))]
  
  # correct CTD oxy sensor using "correct_oxy.r" function
  # corrected oxy is oxyc
  bsq$oxyc=correct_oxy(ctd_oxy,winkler, mission,oxy_sensor=oxy_sensor) 
  
  # add corrected oxy to qat dataframe qf
  qfc=merge(bsq[,c("id","oxyc")],qf,by="id",all.x=T,all.y=T)
  
  # replace original qat oxy with corrected oxy
  qf$oxy=qfc$oxyc
  
  oxy_flag=1
  
}

# qf is final qat file that has only one column for each sensor.
# the sensors used for each variable are stored in the "original_sensors" variable
# if correction of CTD oxygen data is applied using winkler "oxy_flag" is set to 1
# if there was no CTD oxy correction "oxy_flag" is set to 0

# ------------------------------------ #
# RENAME QAT SENSORS TO BIOCHEM METHOD #
# ------------------------------------ #

sensors=c("oxy","sal","temp","cond","fluor")

# rename qat sensors to to BioChem names
qatnames=c(sensors,"pressure","ph","par")
bcnames=c("O2_CTD_mLL","Salinity_CTD","Temp_CTD_1968","conductivity_CTD",
          "Chl_Fluor_Voltage","Pressure","pH_CTD_nocal","PAR")

# find corresponding columns
ni=match(names(qf),qatnames)

# rename qat clumns with bcnames
mn=which(!is.na(ni)) # matching names

# create dataframe containing data mapping info
cc=as.data.frame(cbind(names(qf)[mn],bcnames[ni[mn]]))
names(cc)=c("qat_column_name","BioChem_Method")

cat("\n",'\n')
cat("Assigning following BioChem datatypes to QAT columns:")
cat("\n",'\n')
print(cc)

names(qf)[mn]=bcnames[ni[mn]]

# stack data in biochem format
# qss is QAT data stacked
qss=stack_bcdata(qf)

# DONE WITH QAT DATA  #
# =================== #



# =================== #
#   CREATE BCD FILE
# ------------------- #

# 1. put all stacked data together

# qss is stacked QAT file
# mbs is stacked biolsum data
# mhplc is stacked hplc data

ff=rbind(qss,mbs,mhplc) # all data together

# rename the columns to proper names
names(ff)=gsub("variable","DATA_TYPE_METHOD",names(ff))
names(ff)=gsub("value","DIS_DETAIL_DATA_VALUE",names(ff))




# 2. merge data with metadata in BCS file by sample ID
# load bcs_header file

# file name with path
pbcs=file.path(wdpath,mission,paste0(mission,"_BCS_test.csv"))

# load BCS file
bcs=read.csv(pbcs,1)

# check if there is any difference in IDs between BCS and data file
diff=setdiff(unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID),unique(ff$id))

# merge BCS and data file by sample ID
mf=merge(bcs,ff, by.x="DIS_HEADR_COLLECTOR_SAMPLE_ID",by.y="id", all=TRUE)

# check if all the samples have values
which(is.na(mf$DIS_DETAIL_DATA_VALUE))

# add columns for BCD file
mf$DIS_DATA_NUM=seq(1,dim(mf)[1],1)
mf$DIS_DETAIL_DATA_QC_CODE=0
mf$DIS_DETAIL_DETECTION_LIMIT=NA
mf$PROCESS_FLAG="NR"
mf$BATCH_SEQ=0
mf$CREATED_BY=readline("Please enter the name of the person creating the file:")
mf$CREATED_DATE=as.character(now())


# 3. make BCD data file: order the columns and rename if necessary

# name of the columns for BCD file
cols=c("DIS_DATA_NUM","MISSION_DESCRIPTOR","EVENT_COLLECTOR_EVENT_ID","EVENT_COLLECTOR_STN_NAME",
     "DIS_HEADR_START_DEPTH","DIS_HEADR_END_DEPTH","DIS_HEADR_SLAT","DIS_HEADR_SLON",
     "DIS_HEADR_SDATE","DIS_HEADR_STIME","DATA_TYPE_SEQ","DATA_TYPE_METHOD","DIS_DETAIL_DATA_VALUE",
     "DIS_DETAIL_DATA_QC_CODE","DIS_DETAIL_DETECTION_LIMIT","DIS_HEADR_COLLECTOR","DIS_HEADR_COLLECTOR_SAMPLE_ID",
     "CREATED_BY","CREATED_DATE","DATA_CENTER_CODE","PROCESS_FLAG","BATCH_SEQ","DIS_SAMPLE_KEY_VALUE")

# match orcer of BCD columns to the col vector
mm=match(cols,names(mf))

# BCD file is created with proper order of the columns
bcd=mf[,mm]

# rename specific fields

# rename:
names(bcd)[which(names(bcd)=="DIS_HEADR_COLLECTOR")]="DIS_DETAIL_DETAIL_COLLECTOR"
names(bcd)[which(names(bcd)=="DIS_HEADR_COLLECTOR_SAMPLE_ID")]="DIS_DETAIL_COLLECTOR_SAMP_ID"
names(bcd)[which(names(bcd)=="DATA_TYPE_SEQ")]="DIS_DETAIL_DATA_TYPE_SEQ"


# replace HEADR with HEADER
names(bcd)=gsub("HEADR","HEADER",names(bcd))

# now bcd file is ready
# save bcd file
bcd_filename=file.path(wdpath,mission,paste0(mission,"_BCD_test.csv"))
save.csv(bcd, bcd_filename)


#    DONE WITH BCD FILE    #
# ======================== #



# Also, work on CHN data renaming and formating

# merge bsq with HPLC data
#bsqh=merge(bsq,hplc,by.x="id",by.y="ID",all=TRUE)
