# Reads BiolSum file and checks for inconsistencies:
#
# -check if all metadata columns are there
# -computes position in decimal degrees from deg and min lat and lon
# -check if there are characters in Sample ID column (there are often comments there)
# -finds test events
# -check for duplicated Sample ID
# -flaggs text Sample ID (1), test CTD casts (2) and duplicated samples (3)
# -assigns BioChem gear sequence of 90000019 (10L Niskin bottles)
# -formats date and time as required for BioChem (12-Apr-2013 for date and 1125 for time)
# -creates date-time column for further time calculations
# -writes test results into report file
# 
# Input is the BiolSum file name along with the path.
# Output is a data frame containing all records as original data with flags added (flag column).
#
# BioChem Reload Project, Gordana Lazin, Dec 1, 2015


check_biolsum = function(filename) {


# read BiolSum 

# figure out if the file is csv or xls or xlsx
csv=grep(".csv",filename)
xls=c(grep(".xls",filename),grep(".xlsx",filename))

if (length(csv)>0) {
  # read BiolSum file in csv format
  cat("\n", "\n")
  cat("Reading BiolSum in csv format...")
  bsum_original=read.csv(filename, stringsAsFactors=FALSE)}

if (length(xls)>0) {
  # read the file in xls format
  cat("\n", "\n")
  cat("Reading BiolSum in excel format. It may take up to 40 seconds...")
  bsum_original=read.xlsx(filename, stringsAsFactors=FALSE, sheetName ="BIOLSUMS_FOR_RELOAD")
  
  bsum_original$sdate=as.character(bsum_original$sdate) 
}


# delete extra rows and columns with all NA (excel garbage)
bsum_original=clean_xls(bsum_original)


# check if there is decimal position, if not compute (assumes that there is position in deg and min)
# end position not needed for BiolSum
position=c("slat","slon")

if (length(which(position %in% names(bsum_original)))!=2) {
  bsum_original$slat=bsum_original$slat_deg + bsum_original$slat_min/60
  bsum_original$slon=-abs(bsum_original$slon_deg + bsum_original$slon_min/60)
}

# columns needed for header file
bsum_cols=c("ctd","event","station","sdate","stime","slat","slon","id","depth")

# convert depth to numeric, just in case if there is any text in the depth column
bsum_original$depth=as.numeric(bsum_original$depth)


# check if BiolSums has all the columns needed and write out the messages
sink(file=report_file,append=TRUE, split=TRUE)

if (length(bsum_cols)!= length(which(bsum_cols %in% names(bsum_original))) ) { 
  # missing columns 
  missing_bsum=bcols[!(bsum_cols %in% names(bsum_original))]
  # ad missing columns and assign missing columns to NA
  blog[,missing_bsum]=as.numeric(NA)
  cat(c("\n","\n"))
  cat("-> BiolSum Check: Columns missing, values assigned to NA:", mising_bsum)
} else {
  cat(c("\n","\n"))
  cat("-> BiolSum Check: All columns found.")
}
sink()


# subset BiolSums to needed columns
bsum=bsum_original[,bsum_cols]

# add a column for flags: 
# 0=all good, 1=text in the sample ID, 2=test events, 99=duplicats
bsum$flag=0

#----------------#
# BIOlSUM CHECKS #
#----------------#

# == FIND IF THERE ARE CHARACTERS IN SAMPLE ID COLUMN == #

idnums=as.numeric(gsub("[[:alpha:]]","",bsum$id)) # id numbers
idtxt= which(is.na(idnums))

# write a mesage if text foud i ID column
sink(file=report_file,append=TRUE, split=TRUE)
if (length(idtxt)>0) {
  bsum$flag[idtxt]=1
  cat("\n","\n")
  cat(paste("-> BiolSum Check:",length(idtxt), "strings in Sample ID:"))
  cat("\n","\n")
  print(bsum[idtxt,c(8,1:7,9:10)],row.names = FALSE)
  cat("\n","\n")
  cat("-> BiolSum Check: Records with text sample ID flagged as 1.")
  cat("\n","\n")
  op=readline("Would you like to remove those records now (y or n)?: ")
  if (op=="y") {
    bsum=bsum[-idtxt,]
    idnums=idnums[-idtxt]
    cat("-> BiolSum Check: Records with text sample ID removed as requested.")
  }
  
} else {
  cat(c("\n","\n"))
  cat("-> BiolSum Check: No strings found in Sample ID column.")
}
sink()



# == FIND TEST EVENTS == #

tests=which(bsum$id==999999 | idnums<100)
test_events=unique(bsum$event[tests]) # these test events will be deleted later

# print test casts
sink(file=report_file,append=TRUE, split=TRUE)
if (length(tests)>0) {
  bsum$flag[tests]=2
  cat("\n","\n")
  cat(paste("-> BiolSum Check:",length(tests), "test CTD records found:"))
  cat("\n","\n")
  print(bsum[tests,c(8,1:7,9:10)],row.names = FALSE)
  cat("\n","\n")
  cat("-> BiolSum Check: Test records flagged as 2.")
  cat("\n","\n")
  op=readline("Would you like to remove those records now (y or n)?: ")
  if (op=="y") {
    bsum=bsum[-tests,]
    cat("-> BiolSum Check: Records for CTD test casts removed as requested.")
  }
  
} else {
  cat(c("\n","\n"))
  cat("-> BiolSum Check: No test CTD casts found.")
}
sink()


# == CHECK FOR DUPLICATED SAMPLE IDs == #

ds=bsum$id[which(duplicated(bsum$id))] # duplicated sample IDs

sink(file=report_file,append=TRUE, split=TRUE)
if (length(ds)>0) {
  issues=issues+1
  i=which(bsum$id %in% ds) # index of duplicated ID
  bsum$flag[i]=99
  # write warrning
  cat(c("\n", "\n"))
  cat(paste("-> BiolSum Check: Issue",issues, "- Duplicate Sample ID:"), ds)
  cat(c("\n", "\n"))
  print(bsum[i,])
  cat(c("\n", "\n"))
  cat("-> Duplicated Sample ID not removed and are flagged as 99.")
} else {
  cat(c("\n", "\n"))
  cat("-> BiolSum Check: No duplicate Sample ID found.")
}
sink()

# DONE WITH BIOLSUMS CHECKS #


#insert gear sequence
bsum$GEAR_SEQ=90000019

# format date to dd-mmm-yyyy format
bsum$sdate=format_date(bsum$sdate)

# format time to HHMM format
bsum$stime=format_time(bsum$stime)

# make date_time column in R format that ca be used for computation
bsum$date_time=strptime(paste(bsum$sdate,bsum$stime), "%d-%b-%Y %H%M", tz="GMT")

# create bsum file for header with _bs in column name
bsum_header=bsum

# rename columns
names(bsum_header)=paste0(names(bsum_header),"_bs")

# done with BiolSum
cat("\n", "\n")
cat("BiolSum check completed.")

return(bsum_header)

}