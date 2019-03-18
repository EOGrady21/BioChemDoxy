# Read and check CTD metadata
#
# Written by Gordana lazin, BioChem Reboot Project, December 2015

check_ctd_metadata_comp = function(filename) {
  
  # read CTD metadata (created from ODF file headers)
  
  # figure out if the file is csv or xls or xlsx
  csv=grep(".csv",filename)
  xls=c(grep(".xls",filename),grep(".xlsx",filename))
  
  if (length(csv)>0) {
    # read CTD metadata file in csv format
    cat("\n", "\n")
    cat("Reading CTD meatdata in csv format...")
    odf_original=read.csv(filename, stringsAsFactors=FALSE)}
  
  if (length(xls)>0) {
    # read the file in xls format
    cat("\n", "\n")
    cat("Reading CTD metadata in excel format. It may take up to 40 seconds...")
    odf_original=read.xlsx(filename, stringsAsFactors=FALSE, sheetName ="ODF_INFO") 
  }
  
  
  # delete rows and columns with all NA (excel garbage)
  odf_original=clean_xls(odf_original)
  
  
  # select only down casts
  odf=odf_original[which(odf_original$Event_Qualifier2=="DN"),]
  
  # define flag
  odf$flag=0
  
  # check if any event had 2 or more CTD casts
  imulti=which(odf$Event_Qualifier1>1)
  multiple_event=unique(odf$Event_Number[imulti])
  multi_lines=which(odf$Event_Number %in% multiple_event)
  
  #sink(file=report_file,append=TRUE, split=TRUE)
  if (length(multiple_event)>0) {
    issues=issues+1
    odf$flag[imulti]=1
    # write warrning
    cat("\n", "\n")  
    cat(paste("-> CTD metadata check: Issue",issues, "- Multiple CTD casts for following events:"), multiple_event)
    cat("\n", "\n")
    print(odf[multi_lines,c("File_Name","Event_Number","Event_Qualifier1","Start_Date_Time","Initial_Latitude","Initial_Longitude")])
    
  } else {
    cat("\n", "\n")
    cat("-> CTD metadata check: No multiple CTD casts detected.")
  }
  #sink()
  
  # create start date time in posixlt format
  odf$start_date_time=as.POSIXlt(odf$Start_Date_Time)
  
  # assuming that odf headers have standard column names
  odfcols=c("Cruise_Number","Event_Number","start_date_time","Sounding",
            "Initial_Latitude","Initial_Longitude","flag")
  
  # subset odf, keep columns for header. data frame to merge is odf_header
  odf_header=odf[,odfcols]
  
  # make longitude negative
  odf_header$Initial_Longitude=-abs(odf_header$Initial_Longitude)
  
  names(odf_header)=paste0(names(odf_header),"_odf")
  
  # done with ODF header file
  cat("\n", "\n")
  cat("CTD metadata check completed.")
  
  odf_list=list(odf_info=odf[1,],odf_header=odf_header)
  
  return(odf_list)
  
}
