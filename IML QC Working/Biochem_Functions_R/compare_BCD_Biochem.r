# compares BCD data with data from BioChem discrete data table

source("query_biochem.r")
require("lubridate")

# read the csv file with all cruise names and descriptors
#cn=read.csv("AZMP_mission_name_descriptor.csv",stringsAsFactors = FALSE)
cn=query_biochem("select distinct MISSION_DESCRIPTOR from AZMP_MISSIONS_BCD;") # list of all descriptor in BCD table



for (i in 1:length(cn[,1])) {

desc=cn[i,1]

report_file=paste0(desc,"_comparison_report.txt")
# write input files into report
sink(file=report_file,append=F, split=TRUE)

cat("\n")
cat("\n")
cat(paste("Comparing BCD records with BioChem for mission", desc,", created", now()))
cat("\n")
cat("========================================================================================")
cat("\n")



colmap=read.csv("bcd_bc_column_names.csv", stringsAsFactors = F)
tags=read.csv("AZMP_all_counts_comparison_tagged.csv", stringsAsFactors = FALSE)
tagd=tags[which(tags$DESCRIPTOR==desc),]


# load BCD file for all cruises
#bcd=read.csv("AZMP_BCD_BC.csv",stringsAsFactors=F)
#bcd_desc=bcd[which(bcd$MISSION_DESCRIPTOR==desc),] # bcd for one cruise

#====== get one mission data from BioChem DISCRETE_DATA table and BCD table===

# select mission data from BioChem
bc_query=paste0("select *
from biochem.discrete_data
             where descriptor in ('", desc, "')
             and (upper(collector_station_name) not like 'F%LAB%' and upper(gear_type) not like 'PUMP%')
             ORDER BY COLLECTOR_SAMPLE_ID;")

bc=query_biochem(bc_query) # run the query


# select mission data from BCD
bcd_query=paste0("select * from LAZING.AZMP_MISSIONS_BCD where MISSION_DESCRIPTOR='", desc,"';")

bcd=query_biochem(bcd_query)

# ===== Done with queryng BioChem ====


cols=2:17 # columns in BCD file that I want to look at

#bcd_cols=colmap$BCD_COLUMN_NAME[cols]
bcd1=bcd[,cols] # BCD file for certain columns

# rename columns from BioChem to short names
ibc=match(colmap$BC_COLUMN_NAME[cols],names(bc))
ibc=ibc[!is.na(ibc)] # indices of the columns on BioChem file that match BCD columns

bc1=bc[,ibc]

# rename columns in both files
names(bc1)=colmap$SHORT_NAME[cols]
names(bcd1)=colmap$SHORT_NAME[cols]

# now biochem and bcd data are in same format with same column names
# so they will be easier to compare

# Test 1: are all unique sample IDs the same
cat("\n")
cat("**** TEST 1: COMPARING UNIQUE SAMPLE IDs FOR THE WHOLE MISSION:")
cat("\n")
cat("\n")
cat(paste("-> BCD:",length(unique(bcd1$id)),"IDs, BioChem:",length(unique(bc1$id)),"IDs" ))
cat(c("\n","\n"))

id_not_in_bcd=setdiff(unique(bc1$id),unique(bcd1$id)) # check for IDs that are not in BCD

id_not_in_biochem=setdiff(unique(bcd1$id),unique(bc1$id)) # check for IDs not in Biochem

if (length(id_not_in_bcd)>0) {
cat(paste0("-> ", length(id_not_in_bcd)," Sample IDs found in BioChem but NOT in BCD:"))
cat("\n")
cat("\n")
print(id_not_in_bcd)
cat("\n")
cat("\n")
ind=which(bc1$id %in% id_not_in_bcd) # indices of the records not in BCD
print(bc[ind,c(2,9,13,17,18,35,38,39,41,42,44,51)])
}

if (length(id_not_in_biochem)>0) {
  cat(c("\n","\n"))
  cat(paste0("-> Sample IDs found in BCD but NOT in BioChem:"))
  cat("\n")
  cat("\n")
  print(id_not_in_biochem) }


# Test 2: check IDs for each parameter
cat("\n")
cat("\n")
cat("**** TEST 2: COMPARING SAMPLE IDs FOR EACH PARAMETER SEPARATELY:")
cat("\n")


parameters=unique(tagd$tag)
parameters[-which(parameters=="")] # delete empty spaces
#parameters=parameters[-c(grep("press",parameters),grep("par",parameters))]

# get only parameters taht appear twice


for (j in 1:length(parameters)) {

  pr=parameters[j]
  cat("\n")
  

  
#pr=readline("Which parameter would you like to compare?:")

mbcd1=tagd$METHOD[which(!is.na(tagd$BCD) & tagd$tag==pr)]
mbc1=tagd$METHOD[which(!is.na(tagd$BIOCHEM) & tagd$tag==pr)]

bcd1p=bcd1[which(bcd1$method==mbcd1),] #dataframe from BCD containing desired parameter
bc1p=bc1[which(bc1$method==mbc1),] # dataframe from Biochem containing desired parameter

cat("\n")
cat("\n")
cat(paste("-> Checking", pr,"--",length(unique(bcd1p$id)), "IDs in BCD; ",length(unique(bc1p$id)),"IDs in BioChem"))
cat("\n")
cat("\n")
# compare IDs

ninbc=sort(setdiff(bcd1p$id,bc1p$id)) # not in biochem
ninbcd=sort(setdiff(bc1p$id,bcd1p$id)) # not in BCD

if (length(ninbcd)>0) {
  cat(paste("->", length(ninbcd), pr,"Sample IDs found in BioChem but NOT in BCD:"))
  cat("\n")
  cat("\n")
  print(ninbcd)
  cat("\n")
  cat("\n")
  ind=which(bc1p$id %in% ninbcd) # indices of the records not in BCD
  print(bc1p[ind,])
}

if (length(ninbc)>0) {
  cat("\n")
  cat("\n")
  cat(paste0("-> Sample IDs found in BCD but NOT in BioChem:"))
  cat("\n")
  cat("\n")
  print(ninbc)
  cat("\n")
  cat("\n")}

}

sink()

}

# ind1=which(bc1p$id %in% ninbcd)
# 
# ind2=which(bc1$id %in% ninbcd)
# 
# bc2=bc1[ind2,]
# 
# bc1[which(bc1$id==243528),]






