# plot flagged profiles using BC flagged file

source("flagcol2.r")

# load flagged BCD file
mission="HUD2006008"

fn=file.path(getwd(),mission,paste0(mission,"_BCD_flagged.csv"))

df=read.csv(fn, stringsAsFactors=FALSE)



# find events for which the dat was flagged

# 1. find indices of flagged data, fi
fi=which(df$DIS_DETAIL_DATA_QC_CODE>1)

# 2. Find flagged events, fe
fe=unique(df$EVENT_COLLECTOR_EVENT_ID[fi])


# plot all data for that event

for (i in 1:length(fe)) {
  
  # dataframe for one event
  d=df[which(df$EVENT_COLLECTOR_EVENT_ID==fe[i]),] 
  
  # find unique methods
  um=unique(d$DATA_TYPE_METHOD) 
  
  # remove HPLC variable, will not plot those profiles
  hplc=grep("HPLC",um) # HPLC variable
  
  if (length(hplc)>0) {
    um=um[-hplc]
  }
  
  
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
  
  dp=d[,c("DIS_HEADER_START_DEPTH","DIS_DETAIL_DATA_VALUE","DATA_TYPE_METHOD","DIS_DETAIL_DATA_QC_CODE")]
  
  names(dp)=c("depth","value","method","qc")
  
 
  # ====== MAKE PLOTS =======
  #dev.new(width=10, height=4)
  #png(file="mygraphic.png",width=1200,height=350)
  
  #par(mfrow=c(1,8), oma=c(0,0,2,0))
  
  plotname=paste0(mission,"_profiles_event_",fe[i],".png")
  
  png(file=plotname,width=750,height=750)
  
  par(mfrow=c(2,4), oma=c(0,0,2,0))
  
  
  # 1. temperature
  plot(dp$value[temp],-dp$depth[temp], main="Temperature",type="b", xlab="Temperature [C]", ylab="Depth [m]")
  
  # 2. salinity
  xrange=c(min(dp$value[c(salctd,ssal)]),max(dp$value[c(salctd,ssal)])+0.2)
  plot(dp$value[salctd],-dp$depth[salctd], main="Salinity",type="b", xlab="Salinity [PSU]", ylab="Depth [m]", xlim=xrange)
  points(dp$value[ssal],-dp$depth[ssal],type="b", col="dodgerblue", pch=16) # plot salinometer salinity
  
  flag=which(dp$qc[c(salctd,ssal)]>1) # find flag index
  if (length(flag)>0){
    clrs=flagcol2(dp$qc[c(salctd,ssal)][flag])
    points(dp$value[c(salctd,ssal)][flag],-dp$depth[c(salctd,ssal)][flag],cex=2,bg=clrs,pch=21)
  }
  
  # 3. oxygen
  xrange=c(min(dp$value[c(o2ctd,o2e,o2w)]),max(dp$value[c(o2ctd,o2e,o2w)])+1)
  plot(dp$value[o2ctd],-dp$depth[o2ctd], main="Oxygen", type="b", xlab="Oxy [ml/l]", ylab="Depth[m]", xlim=xrange)
  points(dp$value[o2e],-dp$depth[o2e], type="b", col="dodgerblue", pch=16)
  points(dp$value[o2w],-dp$depth[o2w], type="b", col="dodgerblue", pch=16)
  
  flag=which(dp$qc[c(o2ctd,o2e,o2w)]>1) # find flag index
  if (length(flag)>0){
    clrs=flagcol2(dp$qc[c(o2ctd,o2e,o2w)][flag])
    points(dp$value[c(o2ctd,o2e,o2w)][flag],-dp$depth[c(o2ctd,o2e,o2w)][flag],cex=2,bg=clrs,pch=21)
  }
  
  
  # 4. pH if there is one
  if (length(ph)>0) {
  plot(dp$value[ph],-dp$depth[ph], main="pH_CTD",type="b",xlab="pH", ylab="Depth [m]")
   
    flag=which(dp$qc[c(ph)]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[c(ph)][flag])
      points(dp$value[c(ph)][flag],-dp$depth[c(ph)][flag],cex=2,bg=clrs,pch=21)
    } } 
  
  # if there is no ph plot empty box
  if (length(ph)==0) {
    php=rep(8,length(dp$depth[temp]))
    plot(php,-dp$depth[temp],pch=' ', xlab="pH",ylab="Depth[m]", xlim=c(7,8.8), main="pH_CTD") }
  
 
  
   # 5. Chlorophyll
  xrange=c(min(dp$value[c(chlctd,chl)]),max(dp$value[c(chlctd,chl)])+0.5)
  
  if(length(chl)>0) {
  plot(dp$value[chl],-dp$depth[chl], main="Chlorophyll", type="b", xlab="Chl [mg/m3]", ylab="Depth[m]", pch=16,col="green", xlim=xrange)
  points(dp$value[chlctd],-dp$depth[chlctd], type="b")
  
  flag=which(dp$qc[c(chlctd,chl)]>1) # find flag index
  if (length(flag)>0){
    clrs=flagcol2(dp$qc[c(chlctd,chl)][flag])
    points(dp$value[c(chlctd,chl)][flag],-dp$depth[c(chlctd,chl)][flag],cex=2,bg=clrs,pch=21)  }
   }
  
  if (length(chlctd)>0 & length(chl)==0) {
    plot(dp$value[chlctd],-dp$depth[chlctd], main="Chlorophyll", type="b", xlab="Chl [mg/m3]", ylab="Depth[m]") }
  
  # 6. Nitrate
  if (length(nit)>0) {
  plot(dp$value[nit],-dp$depth[nit], main="Nitrate", type="b", xlab="Nit [mmol/m3]", ylab="Depth[m]", pch=16,col="dodgerblue")
    
    flag=which(dp$qc[nit]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[nit][flag])
      points(dp$value[nit][flag],-dp$depth[nit][flag],cex=2,bg=clrs,pch=21)  }
  }
    
  
  # 7. phosphate
  if (length(pho)>0){
  plot(dp$value[pho],-dp$depth[pho], main="Phosphate", type="b", xlab="Pho [mmol/m3]", ylab="Depth[m]", pch=16,col="dodgerblue")
    
    flag=which(dp$qc[pho]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[pho][flag])
      points(dp$value[pho][flag],-dp$depth[pho][flag],cex=2,bg=clrs,pch=21)  }
  }

  
  # 8. silicate
  if (length(sil)>0){
  plot(dp$value[sil],-dp$depth[sil], main="Silicate", type="b", xlab="Sil [mmol/m3]", ylab="Depth[m]", pch=16, col="dodgerblue")
    
    flag=which(dp$qc[sil]>1) # find flag index
    if (length(flag)>0){
      clrs=flagcol2(dp$qc[sil][flag])
      points(dp$value[sil][flag],-dp$depth[sil][flag],cex=2,bg=clrs,pch=21)  }
  }
    

  
  
  
  mtext(paste(mission,"event",fe[i]), outer = TRUE, cex = 1.5)
  
  dev.off()
}