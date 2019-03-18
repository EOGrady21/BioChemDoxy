# Check bridge log: read file, check for columns, computes decimal position, convert to propper time format
# check for duplicated events
#
#Written by Gordana Lazin, BioChem Reboot Project, December 2015

check_bridgeLog_comp = function(filename) {
  
  # read time as character to preserve leading zeroes (stime is in format HHMM)
  # blog_original=read.csv(Bridge_log, stringsAsFactors=FALSE)
  
  # figure out if the file is csv or xls or xlsx
  csv=grep(".csv",filename)
  xls=c(grep(".xls",filename),grep(".xlsx",filename))
  
  if (length(csv)>0) {
    # read Bridge log file in csv format
    cat("\n", "\n")
    cat("Reading Bridge log in csv format ...")
    blog_original=read.csv(filename, stringsAsFactors=FALSE)
  }
  
  if (length(xls)>0) {
    # read the file in xls format
    cat("\n", "\n")
    cat("Reading Bridge log in excel format ...")
    cat("\n", "\n")
    blog_original=read.xlsx(filename, stringsAsFactors=FALSE, sheetName ="BRIDGELOG_FOR_RELOAD")
    
    # check if any column is in POSIXct or POSIXlt format
    # poscols=which(sapply(blog_original, is.POSIXct))
    
    #convert dates to characters
    # blog_original$sdate=as.character(blog_original$sdate)
    # blog_original$edate=as.character(blog_original$edate)
  }
  
  
  # delete extra rows and columns with all NA (excel garbage)
  blog_original=clean_xls(blog_original)
  
  
  # columns that are needed for the header file 
  # for CTD only there is no need for end position and end time
  bcols=c("cruise", "event","station", "sdate","stime","edate","etime",
          "slat","slon","elat","elon","sounding","comment1","comment2","utc_offset")
  
  # check if there is decimal position, if not compute (assumes that there is position in deg and min)
  spos=c("slat","slon")
  
  if (length(which(spos %in% names(blog_original)))!=2) {
    blog_original$slat=blog_original$slat_deg + blog_original$slat_min/60
    
    # make longitude alwas negative
    blog_original$slon=-abs(blog_original$slon_deg + blog_original$slon_min/60)
    
  }
  
  # to ensure that the longitude is negative
  blog_original$slon=-abs(blog_original$slon)
  
  
  # check if there is end position
  ep=grep("elat", names(blog_original))
  
  # if there is end position check if they are in decimal deg, if not, compute from deg and min
  if (length(ep)>0) {
    epos=c("elat","elon")
    
    if (length(which(epos %in% names(blog_original)))!=2) {
      blog_original$elat=blog_original$elat_deg + blog_original$elat_min/60
      blog_original$elon=-abs(blog_original$elon_deg + blog_original$elon_min/60) # make longitude negative
    } 
    
  }
  
  
  # check if bridge log has all the columns needed and write the message
  # create missing columns and assign values to NA
  #sink(file=report_file,append=TRUE, split=TRUE)
  if (length(bcols)!= length(which(bcols %in% names(blog_original))) ) {
    
    # missing columns 
    missing_blog=bcols[!(bcols %in% names(blog_original))]
    # ad missing columns and assign missing columns values to NA
    blog_original[,missing_blog]=as.numeric(NA)
    cat(c("\n","\n"))
    cat("-> Bridge Log Check: Columns missing, values assigned to NA:", missing_blog)
    cat("\n", "\n")
  } else {
    cat("\n", "\n")
    cat("-> Bridge Log Check: All columns found.")
    cat("\n", "\n")
  }
  #sink()
  
  
  # subset bridge log, only columns that are neded
  blog=blog_original[,bcols]
  
  # add flag column: all god=0, duplicate events=99
  blog$flag=0
  
  
  # replace zeros in elon and elat with NA (bridge log has zeros for some reason)
  blog$elat[blog$elat==0]=NA
  blog$elon[blog$elon==0]=NA
  
  # convert start and end dates to desired date format (dd-mmm-yyyy) 
  blog$sdate=format_date(blog$sdate) # format_date is custom made function
  
  # if there is end date format it as well
  if (length(blog$edate)>length(is.na(blog$edate))) {
  blog$edate=format_date(blog$edate) }
  
  # convert start and end times to desired time format (HHMM) 
  blog$stime=format_time(blog$stime) # format_time is custom made function
  
  # if there is end time convert taht as well (end time is often NA)
  if (length(blog$etime)>length(is.na(blog$etime))) {
  blog$etime=format_time(blog$etime)}
  
  # create start/end date and time in R date format for doing calculations
  blog$sdate_time=strptime(paste(blog$sdate,blog$stime), "%d-%b-%Y %H%M", tz="GMT")
  
  # end date not working: error on line 72, year is 21013 
  blog$edate_time=strptime(paste(blog$edate,blog$etime), "%d-%b-%Y %H%M", tz="GMT")
  
  
  # check for duplicate events
   de=blog$event[which(duplicated(blog$event))] # duplicate events
  
  # write messages
  #sink(file=report_file,append=TRUE, split=TRUE)
  if (length(de)>0) {
    #issues=issues+1
    di=which(blog$event %in% de)
    blog$flag[di]=99
    # write warrning
    cat("\n", "\n")
    #cat(paste("-> Bridge Log Check: Issue",issues, "- Duplicate events:"), de)
    cat("\n", "\n")
    print(blog[di,c("event","station","sdate","stime", "slat","slon","comment1")],row.names = FALSE)
    cat("\n", "\n")
    op=readline("Are those CTD events (y or n)?: ")
    if (op=="n") {
      blog$flag[di]=0
      cat("-> Bridge Log Check: Duplicated events not flagged as CTD issue.")
    } else {
      cat("\n", "\n")
      cat("-> Bridge Log Check: Duplicated events flagged as CTD issue.")
    }
  } else {
    cat("\n", "\n")
    cat("-> Bridge Log Check: No duplicate events.")
  }
  #sink()
  
  
  
  # add _bl to names in order to distinguish bridge log data after merging
  names(blog)=paste0(names(blog),"_bl")
  
  blog_header=blog
  
  # done with bridge log
  cat("\n", "\n")
  cat("Bridge Log Check completed.")
  
  # merge comments in one column
  # fix comments (replace NA with empty string)
  blog_header$comment1_bl[is.na(blog_header$comment1_bl)]=""
  blog_header$comment2_bl[is.na(blog_header$comment2_bl)]=""
  blog_header$comments_bl=paste(blog_header$comment1_bl, blog_header$comment2_bl)
  
  return(blog_header)
  
}