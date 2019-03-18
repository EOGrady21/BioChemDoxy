# Checks QAT file:
# -reads QAT csv file
# -makes date_time column in R date format 
# -subsets the file to contain columns necessary for constructing header
# -flaggs duplcated sample ID as 99
# -make column contaioning date-time for the last bottle in the cast: last_bottle_datetime
# -adds _qat to the column names
#
# BioChem reboot project, Gordana Lazin, Dec 3, 2015
#
# Version 1: chech_qat1.r modifications
# do not remove test events, just flag them as 2
# do not flag duplicated test events (test events can be duplicated)

check_qat1 = function(filename){
  
  
  # read the QAT file
  qat_original=read.csv(qatFile,stringsAsFactors=FALSE, strip.white=TRUE)
  
  qat=qat_original
  
  # delete empty lines (no CTD_File)
  el=which(qat$ctd_file=="") # empty lines 
  if (length(el) > 0) {
    qat=qat[-el,] }
  
  # for some reason quoted string fields (date and Time) have extra characters,  \"
  # I tried setting quote="\"" in read csv and it didn't help
  # I will just delete those characters for now and ask Jeff how to read it properly
  
  # remove space, backslash and a quote
  qat$date=gsub(" \"","",qat$date)
  qat$time=gsub(" \"","",qat$time)
  
  # remove backslash and a quote
  qat$date=gsub("\"","",qat$date)
  qat$time=gsub("\"","",qat$time)
  
  
  # make a column with Date and Time together in the date format with UTC time zone
  qat$date_time=strptime(paste(qat$date,qat$time), "%b %d %Y %H:%M:%S", tz="GMT")
  qat$date_time=as.POSIXct(qat$date_time) # change format from POSIXlt to POSIXct so you can use aggregate function later
  
  # subset qat file
  # assuming that QAT file has constant column names for each cruise
  qatcols=c("cruise","event","lat","lon","id","date_time","pressure")
  
  
  # qat data that will be used for header (only certain columns)
  qat_header=qat[,qatcols]
  
  
  # add column containing the date_time of the last botle in the event
  # have to aggregate first and find the last bottle date_time for each event
  eet=aggregate(date_time ~ event, data=qat_header, max,na.rm=TRUE)
  names(eet)=c("event","last_bottle_datetime")
  eet$last_bottle_datetime=as.POSIXlt(eet$last_bottle_datetime,"GMT") # change back to original date format
  
  
  # add eet to qat by merging
  qat_header=merge(qat_header,eet, by="event",all=TRUE)
  
  qat_header$date_time=as.POSIXlt(qat_header$date_time) # change back to POSIXlt
  
  
  # == QAT FILE CHECKS == #
  
  # make flag column: all good=0, duplcated sample id=99 
  qat_header$flag=0
  
  # == FIND TEST EVENTS == #
  
  tests=which(qat_header$id==999999 | qat_header$id<10000)
  test_events=unique(qat_header$event[tests]) # these test events will be deleted later
  
  # print test casts
  sink(file=report_file,append=TRUE, split=TRUE)
  if (length(tests)>0) {
    qat_header$flag[tests]=2
    cat("\n","\n")
    cat(paste("-> QAT Check:",length(tests), "test CTD records found:"))
    cat("\n","\n")
    print(qat_header[tests,c(5,1:4,6:9)],row.names = FALSE)
    cat("\n","\n")
    cat("-> QAT Check: Test records flagged as 2.")
    cat("\n","\n")
#     op=readline("Would you like to remove those records now (y or n)?: ")
#     if (op=="y") {
#       qat_header=qat_header[-tests,]
#       cat("-> Qat Check: Records for CTD test casts removed as requested.")
#     }    
  } else {
    cat(c("\n","\n"))
    cat("-> QAT Check: No test CTD casts found.")
  }
  sink()
  
  
  # check if there are duplicated sample id's
  dsq=qat_header$id[which(duplicated(qat_header$id))] # duplicate events

   # indices of duplicate IDs that are not test events
  i=which(qat_header$id %in% dsq & qat_header$flag != 2) 
  
  sink(file=report_file,append=TRUE, split=TRUE)
  if (length(i)>0) {
    issues=issues+1    
    qat_header$flag[i]=99 
    # write warrning
    cat(c("\n", "\n"))
    cat(paste("-> QAT Check: Issue", issues, "- Duplicate Sample ID found:"))
    cat(c("\n", "\n"))
    print(qat_header[i,c(5,1:4,6:9)],row.names=FALSE)
    cat(c("\n", "\n"))
    cat("-> QAT Check: Duplicate Sample ID flagged as 99")   
  } else {
    cat(c("\n", "\n"))
    cat("-> QAT Check: No duplicate Sample ID found.")
  }
  sink()
  
  # DONE WITH QAT CHECKS #
  
  # make longitude negative
  qat_header$lon=-abs(qat_header$lon)
  
  names(qat_header)=paste0(names(qat_header),"_qat")
  
  # done with qat file
  cat("\n","\n")
  cat("QAT file check completed.")
   
  return(qat_header)
}