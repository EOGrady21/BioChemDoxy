# loads flagged IML files and appends flags to the BCD file
# Gordana Lazin, April 2017
#modified to work offline from BIOCHEM
#E. Chisholm January 2019

require(reshape)
require(plyr)
#source("query_biochem.r")
options(warn=1) # display warnings as they happen
# get data directly from staging table incstead of reading csv
Sys.setenv(TZ = "GMT")
Sys.setenv(ORA_SDTZ = "GMT")

# GET THE LIST OF MISSIONS
data <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/Oxy_corrected.csv')
#missions=query_biochem("select distinct MISSION_DESCRIPTOR from AZMP_MISSIONS_BCD;")
#missions=query_biochem("select distinct MISSION_DESCRIPTOR from BIOCHEM.CR_D_HUD2015004_BCD_D;")

#all missions
missions <- unique(data$MISSION_DESCRIPTOR)

#SUBSET MISSIONS FOR RERUN
errors <- c( '18HU94008', '18HU95011', '18NE95008', '18PZ94029', 
            '18PZ97042', '18VA69002' ,
            '18VA70002', '80029')

errs <-  111

#missions <- c('180335056', '18PZ96027', '18HU11043', '18HU11004', '18HU12042', '18HU99022', 
#'18HU02032', '18HU04016', '18HU06019', '18HU07011' , '18HU08009', '18HU09015', '18HU10014',
# '18MF12001')
#missions <- '18MF12001'



#format bcd properly to match file used to create IML format
data$DIS_SAMPLE_KEY_VALUE=paste0(data$MISSION_DESCRIPTOR,"_",sprintf("%03d",data$EVENT_COLLECTOR_EVENT_ID),"_",data$DIS_DETAIL_COLLECTOR_SAMP_ID)



# define empty dataframe that will hold number of flags for each mission
sumtab_all <- data.frame(mission=character(), method=character(),f0=numeric(), f1=numeric(), f2=numeric(),
                         f3=numeric(), f4=numeric(), f7=numeric(), stringsAsFactors=FALSE)


for (j in 1:length(missions)) {

 #mission= missions[[1]] #run one mission at a time
 mission=missions[j]
 # 
  if (mission %in% errors | j %in% errs){ 
    ;
  } else{

cat("\n","\n")
cat(paste("-> Moving flags to BCD file for mission", mission,"..." ))

# 1. Load BCD from BCD staging table

# create a query to select one mision from BCD staging table 
#query=paste0("select * from BIOCHEM.CR_D_HUD2015004_BCD_D where MISSION_DESCRIPTOR like '",mission,"';")
#query=paste0("select * from AZMP_MISSIONS_BCD where MISSION_DESCRIPTOR like '",mission,"';")
#bcd=query_biochem(query) # get BCD table for one mission 

bcd <- data[ data$MISSION_DESCRIPTOR == mission , ]

bcdf=bcd # create bcdf that will hold flags. in bcd all flags are 0

# 2. Create file names for IML flagged files

fn=paste0("QC_",mission,"_IML_format.txt") # create file name for bottle data
#fn2=paste0("QC_",mission,"_IML_format_ctd.txt") # create file name for ctd data
#fn=c(fn1,fn2) # fn has 2 file names, one for bottle data and one for CTD

# file name with path to the QC data
fnp=file.path(getwd(),"QC_V6",fn)

# insert flags into BCD file for all the missions in the loop

#for (i in 1:2) {

# this is how to read iml txt file
#had to add comment.char = '' to avoid issues with # in data frame
df=read.table(fnp, stringsAsFactors=FALSE, sep=";", na.strings = 'NaN', comment.char = '')

names(df)=df[2,] # rename columns using 2nd row
df=df[-c(1,2,3),] # delete first 3 rows

#find which columns include each data type
latind <- grep(names(df), pattern = 'Latitude')
lonind <- grep(names(df), pattern = 'Longitude')
timeind <- grep(names(df), pattern = 'Heure')
dateind <- grep(names(df), pattern = 'Date')
#combine
excludeind <- c(latind, lonind, timeind, dateind)

#d=df[,c(1,5,9:dim(df)[2])] # subset to exclude lat, lon, time and date
d <- df[, -excludeind] #subset to exclude lat, lon, time and date in generalized format to avoid formatting issues

d1=d

# convert all columns excpt first to numeric
d1[,2:dim(d)[2]]=data.frame(sapply(d[,2:dim(d)[2]], as.numeric))

# add sample key value
d1$sample_key=paste0(d1$Fichier,"_",d1$Echantillon)

# find columns with quality flags (qc columns, qcc)
qcc=grep("Q_", names(d1))

# rename columns with the QC flags so they contai variable names
names(d1)[qcc]=paste0("Q_",names(d1)[qcc-1])

sk=grep("sample_key",names(d1)) # find column named sample_key

# dataframe of flags, with sample_key
qcdf=d1[,c(sk,qcc)]

# data frame of data
ddf=d1[,c(sk,qcc-1)]

# melt QC flag dataframe
md=melt(qcdf,"sample_key",na.rm=T, stringsAsFactors=F)
md$variable=as.character(md$variable) # convert factors to characters
names(md)=paste0("qc_",names(md)) # add qc_ in column name so there is no confusion for merging

# add column with variable name that will be used for merging
md$variable=gsub("Q_","",md$qc_variable)

# replace flags 9 with NA
if (length(which(md$qc_value==9))>0) {
mdqc=md[-which(md$qc_value==9),]} else {mdqc=md}

# melt data frame with data
mdd=melt(ddf,"sample_key",na.rm=T, stringsAsFactors=F)
mdd$variable=as.character(mdd$variable) # convert factors to characters

# merge flags with data
m=merge(mdqc,mdd, by.x=c("qc_sample_key","variable"), by.y=c("sample_key","variable"))

# now, match IML names with BCD names
# load map file that matches IML fields to the BCD fields
map=read.csv("BCD_IML_map_upd.csv", stringsAsFactors = FALSE)
#limit map to data types present in BCD to avoid confusion with non unique IML codes
#E chisholm Feb 2019
dtype <- unique(bcd$DATA_TYPE_METHOD)
tmap <- map[map$BCD_FIELDS %in% dtype , ]
map <- tmap


# if this is not ctd file
if (length(grep("_ctd",fnp))==0) {
ind=match(m$variable,map$IML_CODE)
m$DATA_TYPE_METHOD=map$BCD_FIELDS[ind]
} 

# this is ctd file
if (length(grep("_ctd",fnp))==1) {
 m$DATA_TYPE_METHOD=NA
 m$DATA_TYPE_METHOD[which(m$variable =="OXY_XX")]="O2_CTD_mLL"
 m$DATA_TYPE_METHOD[which(m$variable =="SSAL_BS" )]="Salinity_CTD"
 m$DATA_TYPE_METHOD[which(m$variable=="TEMP_RT")]="Temp_CTD_1968" 
 
 # if there is ph include it
 if ( length(grep("pH_01",m$variable))>0){
   m$DATA_TYPE_METHOD[which(m$variable=="pH_01")]="pH_CTD_nocal"   
 }
 
} 





# ==== merge with BCD based on the sample key, value, and DATA_TYPE_METHOD ====


# Match bcd with melted IML file with flags

# create matching string: sample-key-value_method_value. 
# Have to include value so you can match replicates that have same sample ID's
mid=paste0(m$qc_sample_key,"_",m$DATA_TYPE_METHOD,"_",m$value)
bcdid=paste0(bcdf$DIS_SAMPLE_KEY_VALUE, "_",bcdf$DATA_TYPE_METHOD,"_",bcdf$DIS_DETAIL_DATA_VAL)

fr=match(mid,bcdid) # indices of ids in BCD file that match ids in IML file m

fr <- na.omit(fr) #to prevent NA erros in matching vector
# 3, insert flags into BCD
bcdf$DIS_DETAIL_DATA_QC_CODE[fr]=m$qc_value

#} #end of mission loop


# 4. check if everything is matching


# 5. write out BCD with flags

# get the file with the cruise name - descriptor connection
# fnn="mission_name_descriptor.csv"
# nd=read.csv(fnn, stringsAsFactors=F)
# 
# cname=nd$MISSION_NAME[which(nd$MISSION_DESCRIPTOR==mission)]
#cname=gsub("99","HUD99",cname ) # insert HUD for 99 cruises

#cruise names for archived data set
cname <- bcd$MISSION_DESCRIPTOR[1]
#or
#cname <- '' #insert manually
#or
#cname <- bcd$MISSION_DESCRIPTOR[1]
dir.create(file.path(getwd(),'BCD',cname))
outname=file.path(getwd(),'BCD', cname,paste0(cname,"_BCD_flagged.csv")) # name of the file that will be written in the cruise directory

write.csv(bcdf,outname, quote = FALSE, na="", row.names = FALSE) # write out BCD with flags

# summary table for the cruise, describing how many flags for each parameter
sumtab=table(bcdf$DATA_TYPE_METHOD, as.numeric(bcdf$DIS_DETAIL_DATA_QC_CODE))

tabname=file.path(getwd(),'BCD',cname,paste0(cname,"_flag_summary.csv")) 

write.csv(sumtab,tabname) # write out flag summary

cat("\n","\n")
cat(paste("-> Flags sucessfully transfered to BCD file for mission", mission,"."))
cat("\n","\n")
cat("-> Summary of the flags for each parameter:")
cat("\n","\n")
print(sumtab)



# NEW ADDITION: convert sumtab to dataframe and merge them all together

# convert to dataframe
b=as.data.frame.matrix(sumtab)

# add f to the name
names(b)=paste0("f",names(b))

# add column with method and mission
b$method=row.names(b)
b$mission=mission

# bind them all together
sumtab_all=rbind.fill(sumtab_all,b)

}

}

# change NA to 0 in summary table for the flags

sumtab_all[is.na(sumtab_all)]=0

# aggregate results for all cruises, each method separately
all_flags=aggregate(.~method,sumtab_all[,2:8],sum)

write.csv(all_flags,"all_flags_summary.csv", row.names=F)


