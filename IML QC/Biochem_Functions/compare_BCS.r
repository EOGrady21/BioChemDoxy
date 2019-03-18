# compare bcs csv files with what was loaded to biochem
# writes out report file with column comparison for all cruises

# =================== #
# DEFINE REPORT FILE
# =================== #

n=now() # make time stamp to mark the start of processing
timestamp=paste0(year(n), sprintf("%02d",month(n)),sprintf("%02d",day(n)),
                 sprintf("%02d",hour(n)),sprintf("%02d",minute(n)),sprintf("%02d",floor(second(n))))


# name of the report file                 
report_file=paste0(mission,"_BCS_report_COMPARISON_",timestamp, ".txt")
#report_file=file.path(outpath,report_file)

# =========== DONE WITH REPORT FILE ==============


# LIST OF AZMP CRUISES
cruises=c("HUD99054","HUD2000050","HUD2001061","HUD2002064","HUD2003067","HUD2003078","HUD2004055",
          "HUD2005055", "HUD2006052","HUD2007045", "HUD2008037","HUD2009048", "HUD2010049","HUD2011043",
          "HUD2012042", "HUD99003","PAR2000002","HUD2001009","HUD2003005","HUD2004009","NED2005004",
          "HUD2006008","HUD2007001","HUD2008004","HUD2009005","HUD2010006","HUD2011004")

# Start writing to the report file
sink(file=report_file,append=TRUE, split=TRUE)

# loop through cruises and compare BCS files
for (j in 1:length(cruises)) {

mission="HUD2003067" #cruises[j]

cat(c("\n","\n"))
cat(paste("===== COMPARISON FOR MISSION", mission, "======"))

# individual cruise files

bcdpath=file.path(getwd(),mission)
bcd_file=paste0(mission,"_BCD.csv")
bcs_file=paste0(mission,"_BCS.csv")

#bcd=read.csv(file.path(bcdpath,bcd_file), stringsAsFactors=FALSE)
bcs=read.csv(file.path(bcdpath,bcs_file),stringsAsFactors=FALSE)


# rename missions for 1999 cruises
if (mission %in% c("HUD99054","HUD99003")) {
  mission=gsub("[[:alpha:]]","",mission) # remove letters
}

# staging tables from biochem

# bcs_bc contains data from all missions
bcs_bc=read.csv("AZMP_BCS_BC.csv",stringsAsFactors=FALSE)

# bcsbc contains data from particular mission
bcsbc=bcs_bc[which(bcs_bc$MISSION_NAME==mission),]

# mission descriptor
desc=unique(bcsbc$MISSION_DESCRIPTOR)

# bcd_bc contains data from all the missions
bcd_bc=read.csv("AZMP_BCD_BC.csv",stringsAsFactors=FALSE)

# bcd contains biochem data from one particular mission
bcdbc=bcd_bc[which(bcd_bc$MISSION_DESCRIPTOR==desc),]

# order dataframes by DIS_SAMPLE_KEY_VALUE
bcs=bcs[with(bcs, order(DIS_SAMPLE_KEY_VALUE)), ]
bcsbc=bcsbc[with(bcsbc, order(DIS_SAMPLE_KEY_VALUE)), ]

# have to convert the dates to the same format

write.csv(bcs,"BCS_HUD99054.csv", row.names=F)
write.csv(bcsbc,"BCSBC_HUD99054.csv", row.names=F)

# =========================== #
# COMPARE BCS
# now have to compare bcs and bcd

# change dates in both files
# columns with dates

idate=grep("DATE", names(bcs))

# change dates in BCS
bcs[,idate]=lapply(bcs[,idate], function(x) {as.Date(x,"%d-%b-%Y")})

# change the dates in BCS from BioChem
bcsbc[,idate]=lapply(bcsbc[,idate], function(x) {as.Date(x,"%Y-%m-%d")})


# check if column by column if they are identical

for (i in 1: length(names(bcs))) {
  
  tt=identical(bcs[,i],bcsbc[,i])
  ae=all.equal(bcs[,i],bcsbc[,i])
  
  if (tt) {
    #cat(c("\n","\n"))
    #cat(paste0("-> ", names(bcs)[i], " columns for ", mission, " are identical."))
  } else {
    cat(c("\n","\n"))
    cat(paste0("-> WARNING: ", names(bcs)[i], " columns for ", mission, " are NOT identical."))
    cat(c("\n","\n"))
    print(ae)
    
  }
  
}
}

sink()
