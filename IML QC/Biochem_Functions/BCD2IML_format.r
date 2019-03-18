# Create a file from BCD data in a format appropriate for IML QC script in matlab
#
# Gordana lazin, BioChem Reload project March 7, 2017
# Emily Chisholm, Updated for Oxygen Recovery from BioChem Feb 2019



require(reshape)
#source("query_biochem.r")
options(warn=1) # display warnings as they happen

source('convertOxy.R')
# get BCD data
# test data frame 
# bcdo=read.csv("AZMP_BCD_BC.csv",stringsAsFactors = FALSE)

# load map file that matches IML fields to the BCD fields
map0=read.csv("BCD_IML_map_upd.csv", stringsAsFactors = FALSE)

# get data directly from staging  table incstead of reading csv
Sys.setenv(TZ = "GMT")
Sys.setenv(ORA_SDTZ = "GMT")

#bcdo=query_biochem("select * from AZMP_MISSIONS_BCD;") # select BCD table

#connection to biochem database
#bcdo=query_biochem("SELECT * FROM BIOCHEM.CR_D_HUD2015004_BCD_D;")

#EC 01/2019
#change so that runs offline from biochem with data set from shelley
#need BCD file with all data types , not just winkler
#not reading date properly
#fixed 02/2019
bcdo <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/Oxy_corrected.csv')

#test
#bcdo <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/HUD2000050_BCD.csv')

#build sample key value
bcdo$DIS_SAMPLE_KEY_VALUE=paste0(bcdo$MISSION_DESCRIPTOR,"_",sprintf("%03d",bcdo$EVENT_COLLECTOR_EVENT_ID),"_",bcdo$DIS_DETAIL_COLLECTOR_SAMP_ID)
#rename some columns
names(bcdo)[14] <- 'DIS_DETAIL_DATA_VALUE'
names(bcdo)[12] <- 'DIS_DETAIL_DATA_TYPE_SEQ'


desc=unique(bcdo$MISSION_DESCRIPTOR) # all cruises in the BCD

#subset to rerun errors
#desc = c('18OK05644', '18VA17668')

for (i in 1:length(desc)) {
#if ( i %in% c(5, 8)){
  # <- i + 1
  #nested loop to avoid processing cruises producing errors
#}
  
  
  
  print(paste("Loop",i,",",desc[i]))
  
#subset bcd for one mission only
descriptor=desc[i]

bcd=bcdo[which(bcdo$MISSION_DESCRIPTOR==descriptor),]


if ('O2_Winkler_Molar' %in% bcd$DATA_TYPE_METHOD){
  #convert mmol/m**3 data to ml/l
  
  bcd <- convertOxy(bcd, missions = descriptor)
  print(paste('>>> Oxygen values converted for mission' , descriptor))
}

#if ('O2_CTD_mLL' %in% unique(bcd$DATA_TYPE_METHOD)){
  #only run if data includes CTD oxygen      EC
  
  
#d=read.csv("test_4melt.csv")


# load IML example file
# load IML test file
iml_file="BTL_01064.txt"

# this is how to read iml txt file
df=read.table(iml_file, stringsAsFactors=FALSE, sep=";")

# subset df1 to have only metadata, and ctd data
df=df[,c(1:18)]

# === prepare mapping file that relates bcd fields to IML fields ====

# remove lines for which there is no matchin fields
no_match=which(map0$BCD_FIELDS=="" | map0$IML_CODE=="")

map=map0[-no_match,] # remove the lines
#=== Mapping file ready ===


# subset BCD to only include required fields
md=which(names(bcd) %in% map$BCD_FIELDS) # metadata columns
dc=which(names(bcd) %in% c("DATA_TYPE_METHOD" ,"DIS_DETAIL_DATA_VALUE"))
cols=union(md,dc) # column numbers for subsetting

bd=bcd[,cols] # has only needed columns

# subset only certain data types
data_types=map$BCD_FIELDS[which(map$qc== "qc")] # data types that are QC by IML script

# this is now dataframe that will be transformed for to IML format
b=bd[which(bd$DATA_TYPE_METHOD %in% data_types),] # include only methods that are QC by IML script

# trim sample ID from DIS_SAMPLE_KEY_VALUE, so it has only cruiseName_eventNumber
#b$DIS_SAMPLE_KEY_VALUE=substr(b$DIS_SAMPLE_KEY_VALUE,1,14)

# convert to wide format
mcol=which(names(b) %in% c("DIS_SAMPLE_KEY_VALUE","DATA_TYPE_METHOD","DIS_DETAIL_DATA_VALUE")) # desired column indices
wide=cast(b[,mcol],DIS_SAMPLE_KEY_VALUE ~ DATA_TYPE_METHOD, paste, fill=NA, value="DIS_DETAIL_DATA_VALUE") # this can be then merged to BCS metadata


# merge with metadata
bm=merge(wide,unique(b[,1:8]),by="DIS_SAMPLE_KEY_VALUE")  #EC update 02/2019: now 8 metadata columns includes start depth

# make IML file 
mm=match(map$BCD_FIELDS, names(bm)) # match the column names to the map file
mm=unique(mm[which(!is.na(mm))]) # this will be used to re-arrange the columns
bmn=bm[,mm] # dataframe with columns in order


# keep only matching fields and needed columns
mapss=map[which(map$BCD_FIELDS %in% names(bmn)),1:4]

# rename the columns to IML_CODE
names(bmn)[match(mapss$BCD_FIELDS, names(bmn))] = mapss$IML_CODE


# ==== change date and time format======
# add leading zeroes to hour
bmn$Heure=sprintf("%04d", as.numeric(bmn$Heure))

# convert to posixct
#creates NAs in data
#edited to not make NA's ... changed format from "%Y-%m-%d %H%M' to '%d-%b-%Y %H%M'
datetime=as.POSIXct(paste(bmn$Date, bmn$Heure), format="%d-%b-%Y %H%M", tz="GMT")

# Convert date:
#this step is changing dates to NA -- fixed
bmn$Date=tolower(format(datetime,"%d-%b-%y"))

# convert time
bmn$Heure=format(datetime,"%H:%M:%S")

#==== done with date-time format changes ====

# convert bmn to characters
bc=data.frame(lapply(bmn, as.character), stringsAsFactors=FALSE)

# add lines from mapss (unit and CTD/labo tags)
names(bc)=mapss$IML_unit
bc=rbind(names(bc),bc) # add units

names(bc)=mapss$IML_CODE
bc=rbind(names(bc),bc) # add names

names(bc)=mapss$localisation
bc=rbind(names(bc),bc) # add CTD/labo tags

names(bc)=paste0("V",1:dim(bc)[2]) # have names be V1, V2, etc.

# remove sample ID from the column
skl=bc$V1[4] # sample key example
underscore=unlist((gregexpr(pattern ='_',skl)))[2]


# find second underscore
bc$V1=substr(bc$V1,1,underscore-1)




# copy temp, sal, oxy and ph columns and make them labo
# add columns for Temp and Sal and oxy by copying CTD data columns
#bc$oxy=bc[,grep("DOXY",bc[2,])[1]] #find CTD oxygen and add it to data
#bc$temp=bc[,grep("TE90",bc[2,])[1]] #find ctd tempand add it to data 
#bc$sal=bc[,grep("PSAL",bc[2,])[1]] # find ctd salinity

# # check if there is ph
# if (length(grep("PHPH",bc[2,]))>0) {
# bc$ph=bc[,grep("PHPH",bc[2,])[1]] # find ctd ph
# bc$ph[1]="labo"
# bc$ph[2]="pH_01"
# }
# 
# # change CTD to labo
# bc$oxy[1]="labo"
# bc$oxy[2]="OXY_XX"
# 
# bc$sal[1]="labo"
# bc$sal[2]="SSAL_BS"
# bc$sal[3]="(g/kg)"
# 
# bc$temp[1]="terrain"
# bc$temp[2]="TEMP_RT"
# 



# make separate file for CTD data only and for bottle data only
# pick CTD columns only
#nctd=grep("CTD",bc[1,])
#lctd=which(bc[2,] %in% c("OXY_XX","SSAL_BS","TEMP_RT","pH_01"))
#ctd_only=bc[,c(nctd,lctd)] # this is dataframe with CTD data pretended to be labo

#bcl=bc[,-lctd] # this is just bottle data (labo)
bcl = bc

# write out the file
# define the name and path to output file
outpath=file.path(getwd(),"IML_QC") # folder to put the data
outfile=file.path(outpath,paste0(descriptor,"_IML_format.txt")) # for bottle data only
#outfile_ctd=file.path(outpath,paste0(descriptor,"_IML_format_ctd.txt")) # for ctd data only


# this is how to write it out in correct format
# write bottle file
write.table(bcl,file=outfile,sep=";",col.names=FALSE, row.names=FALSE, quote=FALSE, na='NaN')

# write CTD file
#write.table(ctd_only,file=outfile_ctd,sep=";",col.names=FALSE, row.names=FALSE, quote=FALSE, na='NaN')
}
#else{
  #print(paste(desc[i], 'not processed'))
#}
#}

