# plot ODF file with flags

source("sourceDir.r")
pat="C:/ODS_Toolbox/R/R_Code/ODF"
sourceDir(path=pat)

odf="CTD_HUD2016027_227_01_DN.ODF"

a=read_odf(odf)

# dataframe with data
vv=data.frame(a[9])



plot(vv$DATA.OXYV_01, -vv$DATA.PRES_01, type="l", ylab="Pressure", xlab="DATA.TEMP_01")



vv$DATA.QOXYV_01

vv$DATA.QPHPH_01

vv$DATA.QPSAL_02

vv$DATA.QSIGP_01
