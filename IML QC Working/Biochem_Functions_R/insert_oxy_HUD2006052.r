# insert oxy data to biolsum_for_reload sheet

fn="HUD2006052_CHL_BiolSum_GL.xls"


bs=read.xlsx(fn, stringsAsFactors=FALSE, sheetName ="BIOLSUMS_FOR_RELOAD")
bs=clean_xls(bs)


o2=read.xlsx(fn, stringsAsFactors=FALSE, sheetName ="Sheet1")
o2=clean_xls(o2)

# merge dataframes together

mdf=merge(bs,o2,by="id",all.x=TRUE,all.y=TRUE)

# save file as csv
write.csv(mdf, "HUD2006052_biolsum_with_o2.csv")
