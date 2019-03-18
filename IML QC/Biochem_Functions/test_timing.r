# test timing of the script

fn="MADCPS_HUD2013004_1845_1269-42_1800.ODF"
#fn="MCTD_OPL2008022_1692_5346_300.ODF" 
#fn="MCM_HUD2009011_1719_612_3600.ODF"
#fn="CTD_BCD2000667_4_1_DN.ODF"
#fn="MVCTD_HUD2008004_021_003_DN.ODF"
#fn="MTR_BCD2000600_BSBB1_6192_1800.ODF" 

t1=Sys.time()

#dk=read.odf(fn)
gl=read_odf_gl(fn)

t2=Sys.time()
print(t2-t1)

