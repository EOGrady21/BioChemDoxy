# merge BioChem historical data and create BCD table
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
source("get_hplc.r")
source("find_strings_in_data.r")
source("na.columns.r")
source("get_precision.r")

mission="HUD2012042"


# ======================================================== #
# DEFINING WHICH DATA FILES TO READ 
# ======================================================== #
# read inventory created by Emily

wdpath='C:/Gordana/Biochem_reload/working'
setwd(wdpath)

# file that contains list of file names for each cruise
fp="//ent.dfo-mpo.ca/ATLShares/Science/BIODataSvc/SRC/BIOCHEMInventory/Data_by_Year_and_Cruise/Files_for_DIS_header.csv"
files=read.csv(fp, stringsAsFactors=FALSE)

# select files for this particular mission
files=files[files$mission==mission,]

Bridge_log=file.path(files$path,files$Bridge_log)
BiolSum=file.path(files$path,files$BiolSum)
qatFile=file.path(files$path,files$qatFile)
odfFile=file.path(files$path,files$odf)
hplcFile=file.path(files$path,files$hplc)
chnFile=file.path(files$path,files$chn)


# =================== #
# DEFINE REPORT FILE
# =================== #
outpath=file.path(wdpath,mission)

n=now() # make time stamp to mark the start of processing
timestamp=paste0(year(n), sprintf("%02d",month(n)),sprintf("%02d",day(n)),
                 sprintf("%02d",hour(n)),sprintf("%02d",minute(n)),sprintf("%02d",floor(second(n))))

# name of the report file                 
report_file=paste0(mission,"_BCD_report_",timestamp, ".txt")
report_file=file.path(outpath,report_file)

# write input files into report
sink(file=report_file,append=TRUE, split=TRUE)
cat("\n")
cat(paste(mission,"BCD creation log, ", n))
cat("\n")
cat(c("-------","\n","\n"))

cat("Input file:", BiolSum)
cat("\n")
cat("Input file:", qatFile)
cat("\n")
cat("Input file:", hplcFile)
cat("\n")
cat("Input file:", chnFile)
#sink()

# ===============================================#
# load BCS data that will be used for comparison #

# file name with path
pbcs=file.path(wdpath,mission,paste0(mission,"_BCS.csv"))

# load BCS file
bcs=read.csv(pbcs, header=T)

# create data frame that will hold extra samples that are not in BCS file
extra_samples=data.frame(id=character(),file=character(),mission=character(),stringsAsFactors=FALSE)


# ===============================================#



# =========== #
#  HPLC DATA  #
# =========== #

if (!is.na(hplcFile)) {

# get HPLC file (load and match with BoChem METHOD names, return dataframe)
hplc=get_hplc(mission,hplcFile)

#hplc$id=as.numeric(hplc$id)

# stack the data
mhplc=stack_bcdata(hplc)

# compare sale IDs with BCS file
d=setdiff(unique(hplc$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

if (length(d)>0) {
  extra_hplc=as.data.frame(cbind(d,"HPLC",mission),stringsAsFactors=FALSE)
  names(extra_hplc)=c("id","file","mission")
} else {
  extra_hplc=extra_samples
}


} # end of is.na(hplcFile)




# ========== #
#  CHN DATA  #
# ========== #

if (!is.na(chnFile)) {

  
# !!!!!WATCH: CHN HAS DUPLICATES!!!!#


#chn=read_excel(cp,sheet="Results",skip=3) #original sheet
chn=read_excel(chnFile, sheet="CHN_FOR_RELOAD") # reload sheet that has mapped columns

# convert to proper data frame
chn=as.data.frame(chn)

chn0=chn # just to have a copy

# remove NA rows from the dataframe
if (length(na.rows(chn))>0) {
  chn=chn[-na.rows(chn),]
}

# CHN columns
chn_cols=c("id","POC_CHN_mg/m3","PON_CHN_mg/m3" )

# pick the columns with methods
mc=which(names(chn) %in% chn_cols)

# write the message if chn columns are mising
if (length(mc)<3) {
  cat("\n","\n")
  cat("-> CHN data: CHN Coulmns found:", paste(intersect(chn_cols,names(chn)[mc]), collapse=", "))
  cat("\n","\n")
  cat("-> CHN data: CHN Coulmns missing:", paste(setdiff(chn_cols,names(chn)[mc]), collapse=", "))
  cat("\n","\n")
  cat("-> CHN data: Please check CHN file.")
  stop()
}

# if all columns are found

if (length(mc)==3) {
  cat("\n","\n")
  cat("-> CHN data: All necessary columns found:", paste(names(chn)[mc], collapse=", ")) 
  cat("\n","\n")
  chns=chn[,mc] # subset the columns
  mchn=stack_bcdata(chns) #stack the data
  
}

# compare sale IDs with BCS file
dchn=setdiff(unique(mchn$id),unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID))

if (length(dchn)>0) {
  extra_chn=as.data.frame(cbind(dchn,"CHN",mission),stringsAsFactors=FALSE)
  names(extra_chn)=c("id","file","mission")
} else {
  extra_chn=extra_samples
}


} # end of chn part

# write out file with extra samples
extra_samples=rbind(extra_hplc,extra_chn)
extra_samples=extra_samples[order(extra_samples$id),]

if (dim(extra_samples)[1]>0) {
    write.csv(extra_samples,file.path(outpath,paste0(mission,"_extra_samples.csv")), row.names=FALSE)
}


# ======== #
# BiolSum
# ======== #

if (mission== "HUD2009005"){
  # this mission gets out of memeory error when reading excel file
  bsum=read.csv(BiolSum, stringsAsFactors=FALSE)
  bsum=bsum[,-grep("X",names(bsum))] #delete garbage columns
}else{

# read BiolSum
bsum=read.xlsx(BiolSum, stringsAsFactors=FALSE, sheetName ="BIOLSUMS_FOR_RELOAD")
}

bsum=clean_xls(bsum) # clean excel file

# for some reason for cruise HUD99003 id from biolsum is imported as character.
# for that cruise change id coulmn to numeric
if (mission=="HUD99003"){
  bsum$id=as.numeric(bsum$id)
}

# define columns with metadata
bsum_meta=c("ctd","depth","event","station","sdate","stime","slat","slon","doy","slat_deg","slat_min","slon_deg","slon_min","comment","dmcomment")

# keep only data column
bsum=bsum[,!(names(bsum) %in% bsum_meta)]

# fix the header. excel reader reads - as . for some reason
names(bsum)=gsub("Holm.Hansen","Holm-Hansen",names(bsum))

# find electrode oxy data
oe=which(names(bsum) %in% c("O2_Electrode","o2_um"))

# if there is electrode % saturation, or umol data remove those column (we don't need those)
if (length(oe>0)) {
  bsum=bsum[,-oe]
}

# rename o2_mll to electrode mll datatype
mll=which(names(bsum)=="o2_ml")

if (length(mll)>0) {
  names(bsum)[mll]="O2_Electrode_mll"
}

# find if there are any strings mixed up with numeric data
bsum1=find_strings_in_data(bsum)

# make stacked dataset with data type sequences using stack_bcdata function
mbs=stack_bcdata(bsum1)


cat("\n","\n")
cat("-> BiolSum data: Following data found in BiolSum:")
cat("\n","\n")
bsv=data.frame(as.character(unique(mbs$variable))) # list of variables in BiolSum
names(bsv)="BiolSum parameters"
print(bsv)



# ======== #
# QAT file
# ======== #

# read QAT file
qat=read.csv(qatFile,stringsAsFactors=FALSE, strip.white=TRUE)

# define columns with metadata
#qat_meta=c("ctd_file","cruise","event","lat","lon","trip","date","time")

qat_meta=c("ctd_file","cruise","lat","lon","trip","date","time")

# keep only data column
qat=qat[,!(names(qat) %in% qat_meta)]

# check if there are columns with no data
nac=na.columns(qat)

# if there is columns without data write warrning and remove them
if (length(nac)>0) {
  # if there is columns with all na write warrning
  cat(c("\n","\n"))
  cat(" -> QAT data: *** WARNING ***")
  cat(c("\n","\n"))
  cat(" -> QAT data: Following columns contain no data and will be removed from QAT file:")
  cat(c("\n","\n"))
  print(nac)
  qat=qat[,-nac]
  cat(c("\n","\n"))
  cat("-> QAT data: Available columns with data in QAT fle:")
  cat(c("\n","\n"))
  print(names(qat))
}

# visually compare sensors in qat file and save the plots
compare_sensors(qat,mission)


# check ranges of qat data for temp, sal, oxy
check_qat_ranges(qat)

# choose primary or secondary sensors. 
# Output is list that contains a dataframe and name of original sensors.
ll=choose_qat_sensors(qat)

qf=ll$qf #qf is dataframe with qat data that has only one sensor for each parameter
original_sensors=ll$original_sensors # contains names with choices of original sensors


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
cat("-> QAT data: Assigning following BioChem datatypes to QAT columns:")
cat("\n",'\n')
print(cc)

names(qf)[mn]=bcnames[ni[mn]]

# check if there are strings in data
qf1=find_strings_in_data(qf)

# stack data in biochem format
# qss is QAT data stacked
qss=stack_bcdata(qf1)

# DONE WITH QAT DATA  #
# =================== #

cat(c("\n","\n"))
cat(" -> Creating BCD file ...")


# =================== #
#   CREATE BCD FILE
# ------------------- #


# 1. put all stacked data together

# qss is stacked QAT file
# mbs is stacked biolsum data
# mhplc is stacked hplc data
# mchn is stacked CHN data


# all possible data frames
dataFrames=c("mbs","qss","mhplc","mchn")


# check which dataframes exist (is there a file with data)
data_exist=c(!is.na(BiolSum),!is.na(qatFile),!is.na(hplcFile),!is.na(chnFile))

# take only existing dataframes
dataFrames=dataFrames[data_exist]

# rbind existing dataframes together (stack them)
# have to do it through eval: make an expression string
# ff=rbind(qss,mbs,mhplc,mchn)

eval_expr= paste("ff=rbind(",paste(dataFrames ,collapse=","), ")" )

# evaluate expression
eval(parse(text=eval_expr))

# rename the columns to proper names
names(ff)=gsub("variable","DATA_TYPE_METHOD",names(ff))
names(ff)=gsub("value","DIS_DETAIL_DATA_VALUE",names(ff))




# 2. merge data with metadata in BCS file by sample ID
# load bcs_header file

# file name with path
pbcs=file.path(wdpath,mission,paste0(mission,"_BCS.csv"))

# load BCS file
bcs=read.csv(pbcs, header=T, stringsAsFactors = FALSE )

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

# merge BCS and data file by sample ID
mf=merge(bcs,ff, by.x="DIS_HEADR_COLLECTOR_SAMPLE_ID",by.y="id", all=TRUE)

# check if all the samples have values
which(is.na(mf$DIS_DETAIL_DATA_VALUE))

# remove extra sample IDs
exid=which(mf$DIS_HEADR_COLLECTOR_SAMPLE_ID %in% extra_samples$id)
if (length(exid)>0){
  mf=mf[-exid,]
  cat(c("\n","\n"))
  cat(paste("->", length(unique(extra_samples$id)), "Extra samples removed from BCD."))
  cat(c("\n","\n"))
}

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

#5. Change factors to 

#6. replace "O2_Winkler with O2_Winkler_Auto



# now bcd file is ready
# save bcd file
bcd_filename=file.path(wdpath,mission,paste0(mission,"_BCD.csv"))
write.csv(bcd, bcd_filename, quote = FALSE, na="", row.names = FALSE )

cat(c("\n","\n"))
cat(paste("-> BCD file created:",bcd_filename))
cat(c("\n","\n"))
cat(paste0("-> Data in BCD for ", mission,":") )
cat(c("\n","\n"))
tt=data.frame(table(bcd$DATA_TYPE_METHOD))
names(tt)=c("Data Type","Number of Records")
print(tt)

sink()

#    DONE WITH BCD FILE    #
# ======================== #


