# check QAT files for HUD2001-061 versus ODF files

source("read_odf.r")
source("define_ODF_header.R")

# paths to the files
odf_path="C:/Gordana/Biochem_reload/qat_fix/HUD2001061/odf"
qat_path="C:/Gordana/Biochem_reload/qat_fix/HUD2001061/odf/qat_original/all_records_originals" 

# file names to fix
odf="CTD_HUD2001061_019_01_DN.ODF"
qat="061a019.tem"

# file names to fix
odf="CTD_HUD2001061_023_01_DN.ODF"
qat="061a023.csv"

# file names to fix
odf="CTD_HUD2001061_032_01_DN.ODF"
qat="061a032.csv"


# file names to fix
odf="CTD_HUD2001061_033_01_DN.ODF"
qat="061a033.csv"

# file names to fix
odf="CTD_HUD2001061_039_01_DN.ODF"
qat="061a039.csv"

# file names to fix
odf="CTD_HUD2001061_048_01_DN.ODF"
qat_original="061a048.csv"
qat="061a048.qat"

# file names to fix
odf="CTD_HUD2001061_050_01_DN.ODF"
qat="061a050.csv"

# file names with path
odfp=file.path(odf_path,odf) # ODF file name with path
qat=file.path(qat_path,qat) #QAT file name with path

# read the files
a=read_odf(odfp) # read ODF file

df=a$DATA # data from ODF
df[df==-99]=NA # replace -99 with NA


# read qat file
qf=read.csv(qat, header=FALSE, stringsAsFactors=FALSE)

# assign names to the QAT columns (will have to check for every cruise if correct)
names(qf)=c("cruise","event", "lat","lon", "trip","id","date","time",	"dens1",
            "oxy1",	"theta1",	"sal1",	"scan",	"temp1",	"pressure",	"cond1","bottle")

extra_qat=c("dens2","oxy2","theta2", "sal2","temp2","cond2", 
            "fluor1","fluor2",	"ph",	"opt_phase","opt_temp")


#ad extra columns to qat file
qf[,extra_qat]=NA
names_qat=names(qf)
qf$depth=round(qf$pressure)

# merge QAT and odf just for QAT depths
allc=merge(qf,df,by.x="depth", by.y="PRES_01",all.x=TRUE, all.y=FALSE)
newqat=allc # new qat file with columns relaced




# plot profiles for each sensor
qat_sensors=c("dens1","oxy1",	"theta1",	"sal1","temp1","cond1")
odf_sensors=c("SIGP_01","DOXY_01","POTM_01","PSAL_01","TEMP_01","CRAT_01")

for (i in 1:length(qat_sensors)) {
  qi=which(names(allc)==qat_sensors[i]) # find qat sensor
  oi=which(names(allc)==odf_sensors[i]) # find associated odf sensor
  
  odfc=which(names(df)==odf_sensors[i]) # find columnin ODF file
  
  # check if all odf data is na
  if ( all(is.na(df[,odfc]))) {
    cat(paste("There is no ODF data for", odf_sensors[i]))
    next
  }
  
  # plot the data
  
  # plotodf profile
  plot(df[,odfc],-df$PRES_01, pch=19, col="blue",type="b",cex=0.3,xlab=qat_sensors[i], ylab="Pressure")
  
  # polt old qat data
  points(allc[,qi],-allc$depth, pch=0, type="b")
  
  # plot new qat data
  points(allc[,oi],-allc$depth, pch=19, type="b", col="red")
  
  title(odf)
  
  
  
}




# replace qat columns with data from ODF file
newqat$dens1=newqat$SIGP_01 # density
newqat$oxy1=newqat$DOXY_01  # oxygen
newqat$theta1=newqat$POTM_01 
newqat$sal1=newqat$PSAL_01
newqat$temp1=newqat$TEMP_01
newqat$fluor1=newqat$FLOR_01
#newqat$cond1 # this will not be replaced. faulty points will be removed later

# subset just qat coulumn
nq=subset(newqat,select=names_qat)




# MORE INVESTIGATIONS


qat_original="061a048.csv"
qat_original=file.path(qat_path,qat_original)

qat_fixed="061a048.qat"
qat_fixed=file.path(qat_path,qat_fixed)


qo=read.csv(qat_original, header=FALSE, stringsAsFactors=FALSE)

# assign names to the QAT columns (will have to check for every cruise if correct)
names(qo)=c("cruise","event", "lat","lon", "trip","id","date","time",	"dens1",
            "oxy1",	"theta1",	"sal1",	"scan",	"temp1",	"pressure",	"cond1","bottle")

qfix=read.csv(qat_fixed, header=FALSE, stringsAsFactors=FALSE)

# assign names to the QAT columns (will have to check for every cruise if correct)
names(qfix)=c("cruise","event", "lat","lon", "trip","id","date","time",	"dens1",
            "oxy1",	"theta1",	"sal1",	"scan",	"temp1",	"pressure",	"cond1","bottle")


plot(df$TEMP_01,-df$PRES_01, col="blue",type="b", cex=0.5, xlab='Temperature', ylab="Pressure")
title(odf)

points(qo$temp1,-qo$pressure, pch=0)
text(qo$temp1,-qo$pressure, labels=qo$id, pos=3, cex=0.8)

points(qfix$temp1,-qfix$pressure, pch=19,col="red")
text(qfix$temp1,-qfix$pressure, labels=qfix$id, pos=1,cex=0.8,col="red")



# ----------------------------
# EXAMPLE CAST 49
odf="CTD_HUD2001061_048_01_DN.ODF"
odfp=file.path(odp,odf)
qat="061a048.qat"
qat_original="061a048.csv"
qat=file.path(fp,qat)
qat_original=file.path(fp,qat_original)

# ----------------------------
# EXAMPLE CAST 50
odf="CTD_HUD2001061_050_01_DN.ODF"
odfp=file.path(odp,odf)
qat="061a050.qat"
qat_original="061a050.csv"
qat=file.path(fp,qat)
qat_original=file.path(fp,qat_original)
# last bottle was removed, not visible




# --------------------
# read and plot ODF
a=read_odf(odfp)

# data from ODF
df=a$DATA

# plot temperature
plot(df$TEMP_01,-df$PRES_01, type="b", col="blue", xlab="Temperature", ylab="Pressure")
title(odf)
# --------------------


# load and plot QAT file, and QAT original

qf=read.csv(qat, header=FALSE)
qfo=read.csv(qat_original, header=FALSE)

points(qfo$V14,-qfo$V15, pch=19, col="red", cex=1.5)

points(qf$V14,-qf$V15, pch=0, col="black", cex=1.5)
text(qf$V14,-qf$V15, labels=qf$V5, pos=3)
text(qf$V14,-qf$V15, labels=qf$V6, pos=4)


text(qfo$V14,-qfo$V15, labels=qf$V17, cex=1, pos=3)
