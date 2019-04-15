# function that reads inventory and extracts names of the files available for each mission
# Gordana lazin, 17 May 2016

inventory_files <- function(missions) {
  
  wdpath='C:/Gordana/Biochem_reload/working'
  setwd(wdpath)
  
  inventory_1=file.path(wdpath,'data','BioChem Inventory Spresdsheet_EM_GL.xlsx')
  inventory_2=file.path(wdpath,'data','InventoryDetail_EM_GL.xlsx')
  
  # read inventories
  inv1=read.xlsx(inventory_1, stringsAsFactors=FALSE, sheetName ="BioChem Inventory with FileName", startRow=2)
  #inv2=read.xlsx(inventory_2, stringsAsFactors=FALSE, sheetName ="InventoryDetail", startRow=1)
  inv2=read_excel(inventory_2, sheet ="InventoryDetail")
  inv2=as.data.frame(inv2)
  names(inv2)=gsub(" ",".",names(inv2))
  
  # fill in the Year and Mission fields
  inv2= inv2 %>% fill(Year,Mission)
  
  # parameters of interest
  pars=c("CHL","PHAEO","NO3+NO2","NO2","PO4","SiO4","AMMONIA","CHN","HPLC","CTD DATA",
         "SALINITY (SALINOMETER)","O2_CTD","O2_ELECTRODE","O2 (WINKLER)","TEMP CTD",
         "SALINITY CTD","PRESSURE")
  
  # parameters that we don't need for biochem
  avoid=c("ZOO (RINGS)","BRIDGE LOG","CRUISE REPORT","TA","BIONESS","MULTINET","UK_PLANK","BACTERIA","NA","SPM")
  
  # create empty dataframe to hold file names
  
  fdf <- data.frame(mission=character(),
                    biolsum=character(), 
                    chn=character(),
                    hplc=character(),
                    PI=character(),
                    other1=character(),
                    other2=character(),
                    other3=character(),
                    other4=character(),
                    other5=character(),
                    stringsAsFactors=FALSE) 
 
  # create empthy dataset taht will contain BioChem parameters for each mission
  par <- data.frame(mission=character(),
                    parameters=character(),
                    stringsAsFactors=FALSE)
  
   # for each mission fill in the dataframe containing file names and collected parameters
  for (j in 1:length(missions)) {
    
    mission=missions[j]
    
    # fill data frame with NA for that mission
    fdf[j,]=NA
    par[j,]=NA
    
    # identify records for that cruise and desired parameters
    i=which(inv2$Mission==mission & !(inv2$Data.Type %in% avoid))
   
    # if there is no mission with that name in the inventory write that in the file
    # and move to the next mission
    if (length(i)==0) {
      fdf[j,]="mission not found in inventory"
      fdf$mission[j]=mission
      par$mission[j]=mission
      par$parameters[j]="mission not found in inventory"
      next
    }
    
    # find out the names of the files
    files=unique(inv2$File[i])
    files=files[!is.na(files)] # remove NA
    parameters=unique(inv2$Data.Type[i])
    
    
   
    
    
    
    # make a list of files
    
    # find biolsum, chn, hplc, and other
    ibs=grep("biolsum",files,ignore.case=TRUE)
    if (length(ibs)==0) {ibs="NA"}
    
    ichn=grep("chn",files,ignore.case=TRUE)
    if (length(ichn)==0) {ichn="NA"}
    
    ihplc=grep("hplc",files,ignore.case=TRUE)
    if (length(ihplc)==0) {ihplc="NA"}
    
    ipi=grep("PI",files,ignore.case=TRUE)
    if (length(ipi)==0) {ipi="NA"}
    
    iqat=grep("qat",files,ignore.case=TRUE)
    if (length(iqat)==0) {iqat="NA"}
    
    # ipi=grep("pi",files,ignore.case=TRUE)
    # if (length(ipi)==0) {ipi="NA"}
    
    fdf$mission[j]=mission
    fdf$biolsum[j]=paste(files[ibs],collapse=", ")
    fdf$chn[j]=paste(files[ichn],collapse=", ")
    fdf$hplc[j]=paste(files[ihplc], collapse=", ")
    fdf$PI[j]=paste(files[ipi], collapse=", ")
    
    par$mission[j]=mission
    par$parameters[j]=paste(parameters, collapse=", ")
    
    
    # other files
    if (length(files)>0) {
    iother=setdiff(seq(1,length(files),1), c(ibs,ichn,ihplc,iqat,ipi)) # other files on the list
    } else { iother=NULL}
    
    if (length(iother)>0) {
      fo=files[iother]
      for (i in 1:length(fo)) {
        fdf[j,i+5]=fo[i]
      }
      
      
    }
    
  } 
  
  l=list(fdf=fdf,par=par,parameters=parameters)
  
  return(l)
}