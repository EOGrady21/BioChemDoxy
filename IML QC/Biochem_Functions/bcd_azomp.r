# merge BioChem historical data and create BCD table for AZOMP 1999-2012
# Gordana Lazin, BioChem Reboot project, 22-Sep-2017

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
source("get_hplc.r")
source("find_strings_in_data.r")
source("na.columns.r")
source("get_precision.r")

#mission="HUD2012042"
options(warn=1) #display warnings as they happen

# ======================================================== #
# DEFINING WHICH DATA FILES TO READ 
# ======================================================== #
# read inventory created by Emily

wdpath='C:/Gordana/Biochem_reload/working'
setwd(wdpath)

# file that contains list of file names for each cruise
fp="//ent.dfo-mpo.ca/ATLShares/Science/BIODataSvc/SRC/BIOCHEMInventory/Data_by_Year_and_Cruise/AZOMP_cruises_wnotes.xlsx"
files=read.xlsx(fp, sheetName='file_names', startRow=3, stringsAsFactors=FALSE)

# select files for this particular mission
# files=files[files$mission==mission,]

hy1File=file.path(files$path,files$hy1)
chlFile=file.path(files$path,files$CHL_filename_for_reboot)
hplcFile=file.path(files$path,files$hplc)
chnFile=file.path(files$path,files$CHN_filename_for_reboot)
no2File=file.path(files$path,files$no2_ammonia)[13:14] #only last two cruise 2011 and 2012 have no2 and nh3 data.
taFile=file.path(files$path,files$alkalinity)
ticFile=file.path(files$path,files$tic)


# =================== #
# DEFINE REPORT FILE
# =================== #
# outpath=file.path(wdpath,mission)
# 
# n=now() # make time stamp to mark the start of processing
# timestamp=paste0(year(n), sprintf("%02d",month(n)),sprintf("%02d",day(n)),
#                  sprintf("%02d",hour(n)),sprintf("%02d",minute(n)),sprintf("%02d",floor(second(n))))
# 
# # name of the report file                 
# report_file=paste0(mission,"_BCD_report_",timestamp, ".txt")
# report_file=file.path(outpath,report_file)
# 
# # write input files into report
# sink(file=report_file,append=TRUE, split=TRUE)
# cat("\n")
# cat(paste(mission,"BCD creation log, ", n))
# cat("\n")
# cat(c("-------","\n","\n"))
# 
# cat("Input file:", BiolSum)
# cat("\n")
# cat("Input file:", qatFile)
# cat("\n")
# cat("Input file:", hplcFile)
# cat("\n")
# cat("Input file:", chnFile)
# #sink()



# =========================================#
# MAKE A LOOP TO READ DATA FROM ALL CRUISES#
#==========================================#

# All data files should be in the same format so they can be stacked on top of each other


# =========== #
#  CHL DATA   #
# =========== #
# initiate empty dataframes
chlData=NULL

for (i in 1:dim(files)[1]) {
  
  # read fle for one cruise
  tchl=read_excel(chlFile[i],sheet="CHL_FOR_RELOAD")
  
  tchl=as.data.frame(tchl) # convert to data frame
  
  colnm=c("id","Chl_a_Holm-Hansen_F","Phaeo_Holm-HansenF")
  
  tchl=tchl[,colnm] # pick the columns
  
  # stack the data in long format
  mchl=stack_bcdata(tchl)
  
  # add cruise descriptor
  mchl$descriptor=files$descriptor[i]
  
  #chlData=rbind(chlData,tchl)
  
  # stacked data
  chlData=rbind(chlData,mchl)
  
}

  
# =========== #
#  CHN DATA  #
# =========== #
chnData=NULL
for (i in 1:dim(files)[1]) {
  
  # Read chlorophyll file and stack it
  tchn=read_excel(chnFile[i],sheet="CHN_FOR_RELOAD")
  
 # if there are rows with all NA, delete them
  if (length(na.rows(tchn))>0){
  tchn=tchn[-na.rows(tchn),] }
  
  tchn=as.data.frame(tchn)
  
  colnm=c("id","POC_CHN_mg/m3",	"PON_CHN_mg/m3")

  # pick the columns
  tchn=tchn[,colnm]
  
  # stack the data in long format
  mchn=stack_bcdata(tchn)
  
  mchn$descriptor=files$descriptor[i]
  
  chnData=rbind(chnData,mchn)
  
}
  

# =========== #
#  HPLC DATA  #
# =========== #

# HPLC data assembly requires user input (y or n)
# if all 23 fields are present type "y"

hplcData=NULL
  
for (i in 1:dim(files)[1]) {
  
  mission=files$descriptor[i]
  
  # get HPLC file (load and match with BoChem METHOD names, return dataframe)
  hplc=get_hplc(mission,hplcFile[i])
  
  # stack the data in long format
  mhplc=stack_bcdata(hplc)
  
  mhplc$descriptor=mission
  
  hplcData=rbind(hplcData,mhplc)
}


# ========== #
#  HY1 DATA  #
# ========== #

hyStacked=NULL

# Load hy1 data
hy1File="AZOMP_1999-2012_data_hy1.csv"

# read hy file
hyData=read.csv(hy1File,stringsAsFactors=F)

# fix PH data, replace 0 with NA
hyData$pH[which(hyData$pH==0)]=NA

# change Alkalinity to Alkalinity_umol/kg
names(hyData)[names(hyData)=="Alkalinity"]="Alkalinity_umol/kg"

# change pH to pH_insitu_total_f
names(hyData)[names(hyData)=="pH"]="pH_insitu_total_f"

# have to stack hy for each cruise separately so you can add descriptor
for (i in 1:dim(files)[1]) {
  
  mission=files$descriptor[i]
  
  cruise_data=which(hyData$descriptor==mission) # indices for mission

  # columns with data 
  cols=c("id", "Pressure","Temp_CTD_1968","Salinity_CTD", "O2_CTD_mLL","Salinity_Sal_PSS","O2_Winkler_Auto","SiO4_Tech_Fsh",
       "PO4_Tech_Fsh","NO2NO3_Tech_Fsh","conductivity_CTD","Chl_Fluor_Voltage", "PAR","pH_insitu_total_f")

  # extra: before making bcd file, units have to be checkec on this data: ,"cfc11", "cfc12", "cfc113", "ccl4", "MCHFRM", 
  #   "SF6",
  # the records for "NO2", "NH3","Alkalinity_umol/kg", "TIC", in hy1 file were wrong so these data will be loaded from source files

  hy=hyData[cruise_data,cols]
  
  # add pH temperature
  hy$pH_invitro_temp=NA
  hy$pH_invitro_temp[which(!(is.na(hy$pH_insitu_total_f)))]=25

#stack the hy data
mhy=stack_bcdata(hy)

# add descriptor column
mhy$descriptor=mission

# add each mission on top of each other
hyStacked=rbind(hyStacked,mhy)
}



# ====================== #
#  NO2 and AMMONIA DATA  #
# ====================== #

no2Data=NULL

for (i in 1: length(no2File)) {
  
  print(paste("Loop no2",i))
  no2=read_excel(no2File[i],sheet="NUT_FOR_RELOAD")
  no2s=no2[,c("id","Ammonia","Nitrite")] # subset for Ammonia and Nitrite only
  # convert to data frame
  no2s=data.frame(no2s)
  # rename the columns
  names(no2s)[names(no2s)=="Ammonia"]="NH3_Tech_Fsh"
  names(no2s)[names(no2s)=="Nitrite"]="NO2_Tech_Fsh"
  
  # stack data, change in long format and add sequences
  no2Long=stack_bcdata(no2s)
  
  # add descriptor
  no2Long$descriptor=files$descriptor[i+12]  #add descriptor
  
  #merge the files by stacking them on top of each other
  no2Data=rbind(no2Data,no2Long) 
  
}


# ====================== #
#  TOTAL ALKALINITY DATA #
# ====================== #

taData=NULL

for (i in 1:dim(files)[1]) {
  
  print(paste("Loop alkalinity ",i))
  
  # read the file
  ta=read_excel(taFile[i],sheet=1)
  
  # convert to data frame and keep only first two columns
  ta=data.frame(ta)[,1:2]  
  
  # rename columns
  names(ta)=c("id","Alkalinity_umol/kg")
  
  # stack the data in long format
  sta=stack_bcdata(ta)
  
  sta$descriptor=files$descriptor[i]
  
  taData=rbind(taData,sta)
}



# ========= #
#  TIC DATA #
# ========= #

ticData=NULL

for (i in 1:dim(files)[1]) {
  
  print(paste("Loop tic ",i))
  
  # read the file
  tic=read_excel(ticFile[i],sheet=1)
  
  # convert to data frame and keep only first two columns
  tic=data.frame(tic)[,1:2]  
  
  # rename columns
  names(tic)=c("id","TIC")
  
  # stack the data in long format
  stic=stack_bcdata(tic)
  
  stic$descriptor=files$descriptor[i]
  
  ticData=rbind(ticData,stic)
}







# ====================================================#
# cOMPARE SAMPLE idS IN DATA FILES TO THE ONES IN BCS
# =================================================== #

bcsFile="AZOMP_MISSIONS_BCS.csv"

# file name with path
pbcs=file.path(wdpath,bcsFile)

# load BCS file
bcs=read.csv(pbcs, header=T)

# create data frame that will hold extra samples that are not in BCS file
extra_samples=data.frame(id=character(),file=character(),mission=character(),stringsAsFactors=FALSE)


# ========== #
# EXTRA HPLC: compare sample IDs with hplc file
# ========== #

d=setdiff(unique(hplcData$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

# find indices for d
dind=which(hplcData$id %in% d)

if (length(d)>0) {
  extra_hplc_all=hplcData[dind,c("id","variable","descriptor")]
  extra_hplc=unique(extra_hplc_all[,c("id","descriptor")])
} else {
  extra_hplc=extra_samples
}

write.csv(extra_hplc,"AZOMP_extra_hplc.csv",row.names=F)

#=========== #
# EXTRA CHN: compare sample IDs with chn file
#=========== #
d=setdiff(unique(chnData$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

# find indices for d
dind=which(chnData$id %in% d)

extra_chn=NULL
if (length(d)>0) {
  extra_chn_all=chnData[dind,c("id","variable","descriptor")]
  extra_chn=unique(extra_chn_all[,c("id","descriptor")])
} else {
  extra_chn=extra_samples
}


write.csv(extra_chn,"AZOMP_extra_chn.csv",row.names=F)

# ========== #
# EXTRA CHL: compare sample IDs with chL file
# ========== #
d=setdiff(unique(chlData$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

# find indices for d
dind=which(chlData$id %in% d)

extra_chl=NULL
if (length(d)>0) {
  extra_chl_all=chlData[dind,c("id","variable","descriptor","value")]
  extra_chl=unique(extra_chl_all[,c("id","descriptor")])
} else {
  extra_chl=extra_samples
}

write.csv(extra_chl,"AZOMP_extra_chl.csv",row.names=F)

# ========== #
# EXTRA NO2: compare sample IDs with chL file
# ========== #
d=setdiff(unique(no2Data$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

# find indices for d
dind=which(no2Data$id %in% d)

extra_no2=NULL
if (length(d)>0) {
  extra_no2_all=no2Data[dind,c("id","variable","descriptor","value")]
  extra_no2=unique(extra_no2_all[,c("id","descriptor")])
} else {
  extra_no2=extra_samples
}

if (dim(extra_no2)[1]>0) {
write.csv(extra_no2,"AZOMP_extra_no2.csv",row.names=F)
}

# ================= #
# EXTRA ALKALINITY: compare sample IDs with chL file
# ================= #
d=setdiff(unique(taData$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

# find indices for d
dind=which(taData$id %in% d)

extra_ta=NULL
if (length(d)>0) {
  extra_ta_all=taData[dind,c("id","variable","descriptor","value")]
  extra_ta=unique(extra_ta_all[,c("id","descriptor")])
} else {
  extra_ta=extra_samples
}

if (dim(extra_ta)[1]>0) {
  write.csv(extra_ta,"AZOMP_extra_no2.csv",row.names=F)
}

# ================= #
# EXTRA TIC: compare sample IDs in BCS with TIC file
# ================= #
d=setdiff(unique(ticData$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

# find indices for d
dind=which(ticData$id %in% d)

extra_tic=NULL
if (length(d)>0) {
  extra_tic_all=ticData[dind,c("id","variable","descriptor","value")]
  extra_tic=unique(extra_tic_all[,c("id","descriptor")])
} else {
  extra_tic=extra_samples
}

if (dim(extra_tic)[1]>0) {
  write.csv(extra_tic,"AZOMP_extra_no2.csv",row.names=F)
}

# =================== #
#   CREATE BCD FILE
# ------------------- #


# 1. put all stacked data together

# # qss is stacked QAT file
# # mbs is stacked biolsum data
# # mhplc is stacked hplc data
# # mchn is stacked CHN data
# 
# 
# # all possible data frames
# dataFrames=c("mbs","qss","mhplc","mchn")
# 
# 
# # check which dataframes exist (is there a file with data)
# data_exist=c(!is.na(BiolSum),!is.na(qatFile),!is.na(hplcFile),!is.na(chnFile))
# 
# # take only existing dataframes
# dataFrames=dataFrames[data_exist]
# 
# # rbind existing dataframes together (stack them)
# # have to do it through eval: make an expression string
# # ff=rbind(qss,mbs,mhplc,mchn)
# 
# eval_expr= paste("ff=rbind(",paste(dataFrames ,collapse=","), ")" )
# 
# # evaluate expression
# eval(parse(text=eval_expr))

# stack data together, hy1, chl, chn, hplc
ff=rbind(chlData,chnData,hplcData,hyStacked, no2Data,taData,ticData)

# rename the columns to proper names
names(ff)=gsub("variable","DATA_TYPE_METHOD",names(ff))
names(ff)=gsub("value","DIS_DETAIL_DATA_VALUE",names(ff))




# 2. merge data with metadata in BCS file by sample ID, already loaded, bcs
# load bcs_header file

# # file name with path
# pbcs=file.path(wdpath,mission,paste0(mission,"_BCS.csv"))
# 
# # load BCS file
# bcs=read.csv(pbcs, header=T, stringsAsFactors = FALSE )

# check if there is any difference in IDs between BCS and data file
diff=setdiff(unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID),unique(ff$id)) # sample IDs
diff1=setdiff(unique(ff$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

cat(c("\n","\n"))
cat(" -> Comparing BCD and BCS Sample IDs ...")


# write a comment in the report file
if (length(diff1)==0) {
  cat(c("\n","\n"))
  cat(" -> All samples from BCD have metadata in BCS.")
} else {
  cat(c("\n","\n"))
  cat(" -> WARNING!!! Sample IDs in BCD but NOT in BCS:")
  cat(c("\n","\n"))
  print(extra_samples[,1:2], row.names=F)

}
cat(c("\n","\n"))


# merge BCS and data file by sample ID and mission. This will include extra samples as well.
mf0=merge(bcs,ff, by.x=c("DIS_HEADR_COLLECTOR_SAMPLE_ID","MISSION_DESCRIPTOR") ,by.y=c("id","descriptor") , all=TRUE)

 
# Take only records that have DIS_SAMPLE_KEY_VALUE fields populated, i.e., which have BCS record
mf=mf0[-which(is.na(mf0$DIS_SAMPLE_KEY_VALUE)),] # check if the results are good


# # check if all the samples have values
# which(is.na(mf$DIS_DETAIL_DATA_VALUE))
# 
# # remove extra sample IDs
# exid=which(mf$DIS_HEADR_COLLECTOR_SAMPLE_ID %in% extra_samples$id)
# if (length(exid)>0){
#   mf=mf[-exid,]
#   cat(c("\n","\n"))
#   cat(paste("->", length(unique(extra_samples$id)), "Extra samples removed from BCD."))
#   cat(c("\n","\n"))
# }

# add columns for BCD file
mf$DIS_DATA_NUM=seq(1,dim(mf)[1],1)
mf$DIS_DETAIL_DATA_QC_CODE=0
mf$DIS_DETAIL_DETECTION_LIMIT=""
mf$PROCESS_FLAG="NR"
mf$BATCH_SEQ=as.numeric(gsub("[[:alpha:]]","",mission)) #year and mission number
#tech=readline("Please enter the name of the person creating the file:")
mf$CREATED_BY="Gordana Lazin" #tech
mf$CREATED_DATE=format(now(),"%d-%b-%Y")

# add precision to different retreival sequences
# round the values to the precision associted with each retrieval sequence
# find unique data retreival sequences
uSeq=unique(mf$DATA_RETRIEVAL_SEQ)

for (j in 1:length(uSeq)) {
  
  # find records for specific data retreival sequence
  ind=which(mf$DATA_RETRIEVAL_SEQ==uSeq[j])
  
  # get precision for that seq from biochem
  prc=get_precision(uSeq[j]) # this is data frame with min, max, places after, places before decimal point
  
  # this is precision
  precision=prc$PLACES_AFTER
  
  # round data to desired precision
  mf$DIS_DETAIL_DATA_VALUE[ind]=round(mf$DIS_DETAIL_DATA_VALUE[ind],digits=precision)
}





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


#4. Flag all data with flag 4 that is less than zero and temperature less than -2.5C

# records less than zero for all variables
ltz=which(bcd$DIS_DETAIL_DATA_VALUE<0 & bcd$DATA_TYPE_METHOD != "Temp_CTD_1968")

# temperature records out of range
temp_oor=which(bcd$DATA_TYPE_METHOD == "Temp_CTD_1968" & (bcd$DIS_DETAIL_DATA_VALUE< -2.5 | bcd$DIS_DETAIL_DATA_VALUE>35))

# salinity range check: 0 to 50
sal_oor=which(bcd$DATA_TYPE_METHOD == "Salinity_CTD" & (bcd$DIS_DETAIL_DATA_VALUE<0 | bcd$DIS_DETAIL_DATA_VALUE>50))

# oxygen out of range 0-11 ml/l
oxy_oor=which(bcd$DATA_TYPE_METHOD == "O2_CTD_mLL"  & (bcd$DIS_DETAIL_DATA_VALUE<0 | bcd$DIS_DETAIL_DATA_VALUE>11))


# indices of bad values
bad=unique(c(ltz,temp_oor,sal_oor,oxy_oor))

if (length(bad)>0) {
bcd$DIS_DETAIL_DATA_QC_CODE[bad]=4
cat(c("\n","\n"))
cat(paste("-> ",length(bad)," records flagged as erroneous, flag 4:"))
cat(c("\n","\n"))
print(bcd[bad,c("DATA_TYPE_METHOD","DIS_DETAIL_DATA_VALUE", "EVENT_COLLECTOR_EVENT_ID","EVENT_COLLECTOR_STN_NAME","DIS_HEADER_START_DEPTH")])

}else{

cat(c("\n","\n"))
cat("-> Checking for negative values: No negative records.")
}

# Convert BCD factor columns to character. I am not sure why are some columns factors?
fcol=sapply(bcd, is.factor)
bcd[fcol] <- lapply(bcd[fcol], as.character)


#5. Account for the frozen nutrient samples: change DATA_TYPE_METHOD from FRESH to FROZEN 
# for all HL_02 stations
# for HUD2003-038 sample numbers 265601-265886 were fresh, and the rest of the cruise was frozen
# Frozen methods: PO4_Tech_F,NO2NO3_Tech_F,SiO4_Tech_F, NH3_Tech_F, NO2_Tech_F

nutrients_frozen=c("PO4_Tech_F","NO2NO3_Tech_F","SiO4_Tech_F","NH3_Tech_F","NO2_Tech_F")
nutrients_fresh=c("PO4_Tech_Fsh","NO2NO3_Tech_Fsh","SiO4_Tech_Fsh","NH3_Tech_Fsh","NO2_Tech_Fsh")

for (k in 1:length(nutrients_fresh)){
  
  # find indices for HL2 station
  hl2ind=which(bcd$DATA_TYPE_METHOD==nutrients_fresh[k] & bcd$EVENT_COLLECTOR_STN_NAME=="HL_02")
  
  # find indices for sample numbers265601-265886 on HUD2003038 that are fresh
  frind=which(bcd$DATA_TYPE_METHOD==nutrients_fresh[k] & !(bcd$DIS_DETAIL_COLLECTOR_SAMP_ID %in% 265601:265886) & bcd$MISSION_DESCRIPTOR=="18HU03038")
  
  # all indices to relace fresh with frozen
  frozen_ind=c(hl2ind, frind)
  
  if (length(frozen_ind)>0){
  # replace fresh with frozen
  bcd$DATA_TYPE_METHOD[frozen_ind]=nutrients_frozen[k]}
  
}




# now bcd file is ready
# save bcd file
#bcd_filename=file.path(wdpath,mission,paste0(mission,"_BCD.csv"))

bcd_filename="AZOMP_MISSIONS_BCD.csv"
write.csv(bcd, bcd_filename, quote = FALSE, na="", row.names = FALSE )

cat(c("\n","\n"))
cat(paste("-> BCD file created:",bcd_filename))
cat(c("\n","\n"))
cat(paste0("-> Data in BCD for ", mission,":") )
cat(c("\n","\n"))
tt=data.frame(table(bcd$DATA_TYPE_METHOD))
names(tt)=c("Data Type","Number of Records")
print(tt)

# table for each cruise
rc=table(bcd$DATA_TYPE_METHOD,bcd$MISSION_DESCRIPTOR)
write.csv(rc,"AZOMP_record_counts.csv")

#    DONE WITH BCD FILE    #
# ======================== #

#chop up bcd and bcs into cruises chunks

missions=unique(bcd$MISSION_DESCRIPTOR)

for (i in 1:lenght(missions)) {
  
  # chop BCD first
  cribcd=which(bcd$MISSION_DESCRIPTOR==mission[i])
  
  bcd_onecruise=bcd[cribcd,] # select data for one cruise
  
  fn=paste0(mission[i],"_BCD.csv") # output filename
  
  write.csv(bcd_onecruise,fn,quote = FALSE, na="", row.names = FALSE) # write csv
  
  # chop BCS file
  cribcs=which(bcs$MISSION_DESCRIPTOR==mission[i])
  
  bcs_onecruise=bcd[cribcs,] # select data for one cruise
  
  fn=paste0(mission[i],"_BCS.csv") # output filename
  
  write.csv(bcs_onecruise,fn,quote = FALSE, na="", row.names = FALSE) # write csv
  
}


# CHECK WHY IS NUMBER OF RECORDS FOR NUTRIENTS IS NOT THE SAME 

mission="18HU10014"

phoid=bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[which(bcd$MISSION_DESCRIPTOR==mission & bcd$DATA_TYPE_METHOD=="PO4_Tech_Fsh")]

nitid=bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[which(bcd$MISSION_DESCRIPTOR==mission & bcd$DATA_TYPE_METHOD=="NO2NO3_Tech_Fsh")]

silid=bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[which(bcd$MISSION_DESCRIPTOR==mission & bcd$DATA_TYPE_METHOD=="SiO4_Tech_Fsh")]

setdiff(silid,phoid)
