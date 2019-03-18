# plot flagged profiles using BC flagged file

source("flagcol2.r")
require(lubridate)

wd="C:/Gordana/Biochem_reload/working"

# load flagged BCD file
mission="HUD2015004"


fn=file.path(getwd(),mission,paste0(mission,"_BCD_flagged.csv"))

df0=read.csv(fn, stringsAsFactors=FALSE)

# cruise HUD99003 has descriptor 99005
if (mission=="HUD99003") {
  qcmission="HUD99005"
} else { qcmission=mission}



# load QC report files 
qc_folder="C:/Gordana/Biochem_reload/working/IML_QC"
qcf=paste0("QC_data_",substr(qcmission,nchar(qcmission)-4,nchar(qcmission)),"_IML_format.txt")
qcf_ctd=paste0("QC_data_",substr(qcmission,nchar(qcmission)-4,nchar(qcmission)),"_IML_format_ctd.txt")

qcrep=read.table(file.path(qc_folder,qcf), stringsAsFactors=F, sep=";", header=T)
qcrep_ctd=read.table(file.path(qc_folder,qcf_ctd), stringsAsFactors=F, sep=";", header=T)

if (mission %in% c("HUD99054","HUD99003")) {
  qcrep$Filename=paste0("HUD",qcrep$Filename)
  qcrep_ctd$Filename=paste0("HUD",qcrep_ctd$Filename)
  }

# parameters for QC
qcpar=c("Temp_CTD_1968","Salinity_CTD","O2_CTD_mLL","Salinity_Sal_PSS","Chl_a_Holm-Hansen_F","pH_CTD",
        "Chl_Fluor_Voltage", "O2_Electrode_mll","O2_Winkler","NO2NO3_Tech_F","PO4_Tech_F","SiO4_Tech_F")

# retain only parameters for which QC is done
df=df0[which(df0$DATA_TYPE_METHOD %in% qcpar),]

# find events for which the dat was flagged

# 1. find indices of flagged data, fi
fi=which(df$DIS_DETAIL_DATA_QC_CODE>1)

# 2. Find flagged events, fe
fe=unique(df$EVENT_COLLECTOR_EVENT_ID[fi])

# =================== #
# DEFINE REPORT FILE
# =================== #
outpath=file.path(wd,mission)

n=now() # make time stamp to mark the start of processing
timestamp=paste0(year(n), sprintf("%02d",month(n)),sprintf("%02d",day(n)),
                 sprintf("%02d",hour(n)),sprintf("%02d",minute(n)),sprintf("%02d",floor(second(n))))

# name of the report file                 
report_file=paste0("FLAG_report_",mission,"_",timestamp, ".txt")
report_file=file.path(outpath,report_file)

# write input files into report
sink(file=report_file,append=TRUE, split=TRUE)
cat("\n")
cat(paste(mission,"FLAG Report:, ", n))
cat("\n")
cat(c("-----------------------","\n","\n"))



# ========================= #
# PLOT DATA FOR EACH EVENT
# ========================= #

for (i in 1:length(fe)) {
  
  event=sprintf("%03d",fe[i]) # event padded with leading zeroes like 013 or 001
  
  # dataframe for one event
  d=df[which(df$EVENT_COLLECTOR_EVENT_ID==fe[i]),] 
  
  # station name
  station=unique(d$EVENT_COLLECTOR_STN_NAME)
  
  # methods on which QC is applied
  
  
  # find unique methods
  um=unique(d$DATA_TYPE_METHOD) 
  
  
  # group methods by variable
  
  # 1. temperature
  temp=grep("Temp_CTD",d$DATA_TYPE_METHOD) # temperature CTD
  
  # 2. possible salinity, ctd and salinometer
  ssal=grep("Salinity_Sal",d$DATA_TYPE_METHOD) # salinity salinometer
  salctd=grep("Salinity_CTD",d$DATA_TYPE_METHOD) # salinity CTD
  
  
  # 3. Possible oxygen parameters
  o2e=grep("O2_Electrode",d$DATA_TYPE_METHOD) # oxygen electrode
  o2w=grep("O2_Winkler",d$DATA_TYPE_METHOD) # oxygen winkler
  o2ctd=grep("O2_CTD",d$DATA_TYPE_METHOD) # oxygen CTD
  
  # 4. Possible Chlorophyll
  chlctd=grep("Chl_Fluor_Voltage",d$DATA_TYPE_METHOD)
  chl=grep("Chl_a_Holm-Hansen",d$DATA_TYPE_METHOD)
  
  # 5. Nutrients
  nit=grep("NO2NO3_",d$DATA_TYPE_METHOD)
  sil=grep("SiO4_",d$DATA_TYPE_METHOD)
  pho=grep("PO4_",d$DATA_TYPE_METHOD)
  
  ph=grep("pH_CTD",d$DATA_TYPE_METHOD)
  
  dp=d[,c("DIS_SAMPLE_KEY_VALUE","DIS_HEADER_START_DEPTH","DIS_DETAIL_DATA_VALUE","DATA_TYPE_METHOD","DIS_DETAIL_DATA_QC_CODE")]
  
  names(dp)=c("sample_key","depth","value","method","qc")
  
 
  
  # ====== MAKE PLOTS ======= #
  
  # save the flag plots in cruise directory
  plotname=file.path(outpath,paste0(mission,"_flagged_profiles_event_",fe[i],".png"))
  
  # 8 plots in one row
  # png(file=plotname,width=1400,height=400)
  # par(mfrow=c(1,8), oma=c(0,0,6,0))
  
  # 2 rows of 4 plots
  png(file=plotname,width=750,height=750)
  par(mfrow=c(2,4), oma=c(0,0,6,0))

  
  ##### 1. temperature
  t=dp[temp,] # subset for temperature
  t=t[order(t$depth),] # order by depth
  plot(t$value,-t$depth, main="Temperature",type="b", xlab="Temperature [C]", ylab="Depth [m]")
  
  ##### 2. salinity
  s1=dp[salctd,] # subset for ctd salinity
  s1=s1[order(s1$depth),] # order by depth
  
  s2=dp[ssal,] # subset for salinometer salinity
  s2=s2[order(s2$depth),] # order by depth
  
  xrange=c(min(dp$value[c(salctd,ssal)]),max(dp$value[c(salctd,ssal)])+0.2)
  plot(s1$value,-s1$depth, main="Salinity",type="b", xlab="Salinity [PSU]", ylab="Depth [m]", xlim=xrange)
  points(s2$value,-s2$depth,type="b", col="dodgerblue", pch=16) # plot salinometer salinity
  
  flag=which(dp$qc[c(salctd,ssal)]>1) # find flag index
  if (length(flag)>0){
    clrs=flagcol2(dp$qc[c(salctd,ssal)][flag]) # colors for the flags
    points(dp$value[c(salctd,ssal)][flag],-dp$depth[c(salctd,ssal)][flag],cex=2,bg=clrs,pch=21) # plot flags
    
    # make a dataframe of flagged data
    sflagged=merge(s1,s2,by="sample_key", all.x=T)
    
    # remove columns with all na
    sflagged <- sflagged[,colSums(is.na(sflagged))<nrow(sflagged)]
    
    met=grep("method",names(sflagged))
    for (k in 1:length(met)){
      un=unique(sflagged[,met[k]])
      un=un[!is.na(un)]
    names(sflagged)[met[k]-1]=un
    }
    
    sflagged=sflagged[,-met]
    
    cat("-> Flagged SALINITY:")
    cat("\n") 
    cat("\n")
    print(sflagged)
    cat("\n")
    
    
    
    # determine which lines to print from the qc report file
    ltp=which(qcrep_ctd$Filename %in% paste0(mission,"_",event) & qcrep_ctd$Variable==" psal" )
    ltp1=which(qcrep$Filename %in% paste0(mission,"_",event) & qcrep$Variable==" psal" )
    
    cat("\n")
    cat("-> QC repot:")
    cat("\n")
    print(rbind(qcrep_ctd[ltp,],qcrep[ltp1,]))
    
    cat("\n")
    cat("\n")
    cat("\n")
    
  }   
  
  
  ##### 3. oxygen
  o1=dp[o2ctd,] # subset for ctd oxy
  o1=o1[order(o1$depth),] # order by depth
  
  o2=dp[o2e,] # subset for electrode oxy
  o2=o2[order(o2$depth),] # order by depth
  
  o3=dp[o2w,] # subset for electrode oxy
  o3=o3[order(o3$depth),] # order by depth
  
  xrange=c(min(dp$value[c(o2ctd,o2e,o2w)]),max(dp$value[c(o2ctd,o2e,o2w)])+1)
  
  if (dim(o1)[1]>0) {
  plot(o1$value,-o1$depth, main="Oxygen", type="b", xlab="Oxy [ml/l]", ylab="Depth[m]", xlim=xrange)
  points(o2$value,-o2$depth, type="b", col="dodgerblue", pch=16)
  points(o3$value,-o3$depth, type="b", col="dodgerblue", pch=16)
  }
  
  if (dim(o1)[1]==0 & dim(o2)[1]>0){
    plot(o2$value,-o2$depth, main="Oxygen", type="b", xlab="Oxy [ml/l]", ylab="Depth[m]", xlim=xrange)
    points(o3$value,-o3$depth, type="b", col="dodgerblue", pch=16)
    }
    
  
  
  flag=which(dp$qc[c(o2ctd,o2e,o2w)]>1) # find flag index
  if (length(flag)>0){
    clrs=flagcol2(dp$qc[c(o2ctd,o2e,o2w)][flag])
    points(dp$value[c(o2ctd,o2e,o2w)][flag],-dp$depth[c(o2ctd,o2e,o2w)][flag],cex=2,bg=clrs,pch=21)
    
    # make a dataframe of flagged data
    if (dim(o1)[1]>0) {
    o2flagged=merge(o1,merge(o2,o3,by="sample_key", all.x=T),by="sample_key", all.x=T)
    }
    
    if (dim(o1)[1]==0 & dim(o2)[1]>0){
      o2flagged=merge(o2,o3,by="sample_key", all.x=T)
    } 
    
    
    # remove columns with all na
    o2flagged <- o2flagged[,colSums(is.na(o2flagged))<nrow(o2flagged)]
    
    met=grep("method",names(o2flagged))
    for (k in 1:length(met)){
      un=unique(o2flagged[,met[k]])
      un=un[!is.na(un)]
      names(o2flagged)[met[k]-1]=un}
    
    o2flagged=o2flagged[,-met]
    
    cat("-> Flagged OXYGEN:")
    cat("\n") 
    cat("\n")
    print(o2flagged)
    cat("\n")
    
    # determine which lines to print from the qc report file
    ltp=which(qcrep_ctd$Filename %in% paste0(mission,"_",event) )
    ltp1=which(qcrep$Filename %in% paste0(mission,"_",event) )
    
    cat("\n")
    cat("-> QC repot:")
    cat("\n")
    print(rbind(qcrep_ctd[ltp,],qcrep[ltp1,]))
    
    cat("\n")
    cat("\n")
    cat("\n")
    
  }
  
  
  ##### 4. pH if there is one
  if (length(ph)>0) {
    p=dp[ph,] # subset
    p=p[order(p$depth),] # order by depth
    
  plot(p$value,-p$depth, main="pH_CTD",type="b",xlab="pH", ylab="Depth [m]")
   
    flag=which(dp$qc[c(ph)]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[c(ph)][flag])
      points(dp$value[c(ph)][flag],-dp$depth[c(ph)][flag],cex=2,bg=clrs,pch=21)
    } } 
  
  # if there is no ph plot empty box
  if (length(ph)==0) {
    php=rep(8,length(dp$depth[temp]))
    plot(php,-dp$depth[temp],pch=' ', xlab="pH",ylab="Depth[m]", xlim=c(7,8.8), main="pH_CTD") }
  
 
  
   ##### 5. Chlorophyll
  xrange=c(min(dp$value[c(chlctd,chl)]),max(dp$value[c(chlctd,chl)])+0.1)
  
  c1=dp[chl,] # subset 
  c1=c1[order(c1$depth),] # order by depth
  
  c2=dp[chlctd,] # subset 
  c2=c2[order(c2$depth),] # order by depth
  
  if(length(chl)>0) {
  plot(c1$value,-c1$depth, main="Chlorophyll", type="b", xlab="Chl [mg/m3]", ylab="Depth[m]", pch=16,col="dodgerblue", xlim=xrange)
  points(c2$value,-c2$depth, type="b")
  
  flag=which(dp$qc[c(chlctd,chl)]>1) # find flag index
  if (length(flag)>0){
    clrs=flagcol2(dp$qc[c(chlctd,chl)][flag])
    points(dp$value[c(chlctd,chl)][flag],-dp$depth[c(chlctd,chl)][flag],cex=2,bg=clrs,pch=21) 
    
    # make a dataframe of flagged data
    cflagged=merge(c1,c2,by="sample_key", all.x=T)
    
    # remove columns with all na
    cflagged <- cflagged[,colSums(is.na(cflagged))<nrow(cflagged)]
    
    met=grep("method",names(cflagged))
    for (k in 1:length(met)){
      un=unique(cflagged[,met[k]])
      un=un[!is.na(un)]
      names(cflagged)[met[k]-1]=un}
    
    cflagged=cflagged[,-met]
    
    cat("-> Flagged CHLOROPHYLL:")
    cat("\n") 
    cat("\n")
    print(cflagged)
    cat("\n")
    
    # determine which lines to print from the qc report file
    ltp=which(qcrep_ctd$Filename %in% paste0(mission,"_",event) & qcrep_ctd$Variable==" cphl" )
    ltp1=which(qcrep$Filename %in% paste0(mission,"_",event) & qcrep$Variable==" cphl" )
    
    cat("\n")
    cat("-> QC repot:")
    cat("\n")
    print(rbind(qcrep_ctd[ltp,],qcrep[ltp1,]))
    
    cat("\n")
    cat("\n")
    cat("\n")
    
    }
   }
  
  if (length(chlctd)>0 & length(chl)==0) {
    plot(c2$value,-c2$depth, main="Chlorophyll", type="b", xlab="Chl [mg/m3]", ylab="Depth[m]") }
  
  ##### 6. Nitrate
  if (length(nit)>0) {
    
    n=dp[nit,] # subset 
    n=n[order(n$depth),] # order by depth
    
  plot(n$value,-n$depth, main="Nitrate", type="b", xlab="Nit [mmol/m3]", ylab="Depth[m]", pch=16,col="dodgerblue")
    
    flag=which(dp$qc[nit]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[nit][flag])
      points(dp$value[nit][flag],-dp$depth[nit][flag],cex=2,bg=clrs,pch=21) 
      
      cat("-> Flagged NITRATE:")
      cat("\n") 
      cat("\n")
      print(n)
      cat("\n")
      
      # determine which lines to print from the qc report file
      ltp1=which(qcrep$Filename %in% paste0(mission,"_",event) & qcrep$Variable==" ntrz")
      
      cat("\n")
      cat("-> QC repot:")
      cat("\n")
      print(qcrep[ltp1,])
      
      cat("\n")
      cat("\n")
      cat("\n")
      
      }
  }
    
  
  ##### 7. phosphate
  if (length(pho)>0){
    
    pp=dp[pho,] # subset 
    pp=pp[order(pp$depth),] # order by depth
    
  plot(pp$value,-pp$depth, main="Phosphate", type="b", xlab="Pho [mmol/m3]", ylab="Depth[m]", pch=16,col="dodgerblue")
    
    flag=which(dp$qc[pho]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[pho][flag])
      points(dp$value[pho][flag],-dp$depth[pho][flag],cex=2,bg=clrs,pch=21)  
      
      cat("-> Flagged PHOSPHATE:")
      cat("\n") 
      cat("\n")
      print(pp)
      cat("\n")
      
      # determine which lines to print from the qc report file
      ltp1=which(qcrep$Filename %in% paste0(mission,"_",event) & qcrep$Variable==" phos" )
      
      cat("\n")
      cat("-> QC repot:")
      cat("\n")
      print(qcrep[ltp1,])
      
      cat("\n")
      cat("\n")
      cat("\n")
      
      }
  }

  
  ##### 8. silicate
  if (length(sil)>0){
    
    si=dp[sil,] # subset 
    si=si[order(si$depth),] # order by depth
    
  plot(si$value,-si$depth, main="Silicate", type="b", xlab="Sil [mmol/m3]", ylab="Depth[m]", pch=16, col="dodgerblue")
    
    flag=which(dp$qc[sil]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[sil][flag])
      points(dp$value[sil][flag],-dp$depth[sil][flag],cex=2,bg=clrs,pch=21) 
      
      cat("-> Flagged SILICATE:")
      cat("\n") 
      cat("\n")
      print(si)
      cat("\n")
      
      # determine which lines to print from the qc report file
      ltp=which(qcrep_ctd$Filename %in% paste0(mission,"_",event) )
      ltp1=which(qcrep$Filename %in% paste0(mission,"_",event) & qcrep$Variable==" slca")
      
      cat("\n")
      cat("-> QC repot:")
      cat("\n")
      print(qcrep[ltp1,])
      
      cat("\n")
      cat("\n")
      cat("\n")
      
      }
  }
    
  
  mtext(paste(mission,"event",fe[i],", station",station), outer = TRUE, cex = 1.5, line=4)
  
  mtext("Flags: 2 - yellow, 3 - orange, 4 - red, 7 - green      CTD: black   Bottles: blue", outer=TRUE, line=0.5, cex=1.2)
  
  dev.off()
  
}

sink()
