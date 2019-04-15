# compare number of data records in BioChem and reload BCD staging table

source("query_biochem.r")
source("replace_hplc.r")

# read the csv file with all cruise names and descriptors
cn=read.csv("AZMP_mission_name_descriptor.csv",stringsAsFactors = FALSE)
desc=cn$MISSION_DESCRIPTOR # defines mission descriptor


# extract counts from BCD and DISCRETE_DATA tables in Biochem. First create query string:
query="select descriptor, method, 'BIOCHEM' place, count(1)
from biochem.discrete_data
where descriptor in ('18HU04055','18HU05055','18HU03078','18HU99054','18HU00050','18HU01061','18HU02064','18HU03067','18HU06052','18HU07045','18HU08037','18HU09048','18HU11043','18HU10049','18HU11004','18HU12042','18PZ00002','18HU99005','18HU04009','18HU01009','18HU06008','18NE05004','18HU07001','18HU08004','18HU09005','18HU10006','18HU03005')
and (upper(collector_station_name) not like 'F%LAB%' or upper(gear_type) not like 'PUMP')
group by name, descriptor, method
UNION ALL
select mission_descriptor descriptor, data_type_method method, 'BCD' place, count(1)
from lazing.azmp_missions_bcd
group by mission_descriptor, data_type_method;"


# Query eleinates sample IDs collected for PI
# query="select descriptor, method, 'BIOCHEM' place, count(1)
# from biochem.discrete_data
# where descriptor in ('18HU04055','18HU05055','18HU03078','18HU99054','18HU00050','18HU01061','18HU02064','18HU03067','18HU06052','18HU07045','18HU08037','18HU09048','18HU11043','18HU10049','18HU11004','18HU12042','18PZ00002','18HU99005','18HU04009','18HU01009','18HU06008','18NE05004','18HU07001','18HU08004','18HU09005','18HU10006','18HU03005')
# and (upper(collector_station_name) not like 'F%LAB%' or upper(gear_type) not like 'PUMP')
# and COLLECTOR_SAMPLE_ID not in 
# 
# (select distinct COLLECTOR_SAMPLE_ID
# from BIOCHEM.DISCRETE_DATA
# where descriptor in ('18HU04055','18HU05055','18HU03078','18HU99054','18HU00050','18HU01061','18HU02064','18HU03067','18HU06052','18HU07045','18HU08037','18HU09048','18HU11043','18HU10049','18HU11004','18HU12042','18PZ00002','18HU99005','18HU04009','18HU01009','18HU06008','18NE05004','18HU07001','18HU08004','18HU09005','18HU10006','18HU03005')
# and METHOD like 'PP_PI%')
# 
# group by name, descriptor, method
# UNION ALL
# select mission_descriptor descriptor, data_type_method method, 'BCD' place, count(1)
# from lazing.azmp_missions_bcd
# group by mission_descriptor, data_type_method;"

df=query_biochem(query)




# read files with biochem and BCD staging table data counts
#df=read.csv("AZMP_BCSD-BC_counts.csv", stringsAsFactors = FALSE)

allmissions=NULL

# for each mission make a table that has BCD and BIOCHEM data counts side by side
# write the table to csv file
for (i in 1:length(desc)) {

mission=desc[i]


bct=df[which(df$DESCRIPTOR==mission & df$PLACE=="BIOCHEM"),] # biochem table with one mission

bcd=df[which(df$DESCRIPTOR==mission & df$PLACE=="BCD"),] #bcd table with one mission

# if there is HPLC pigments in the methods replace them just with HPLC
hpbc=grep("HPLC_",bct$METHOD) # finds where HPLC method is
hpbcd=grep("HPLC_",bcd$METHOD)

# replace with HPLC
if (length(hpbc)>0) {
  bct=replace_hplc(bct)
}

if (length(hpbcd)>0) {
  bcd=replace_hplc(bcd)
}

# rename count column
cc=grep("COUNT", names(bcd))

names(bcd)[4]="BCD"
names(bct)[4]="BIOCHEM"

bcd=bcd[,!(names(bcd) %in% "PLACE")] # remove place column
bct=bct[,!(names(bct) %in% "PLACE")] # remove place column


mdf=merge(bcd,bct, by=c("DESCRIPTOR","METHOD"), all=T)

write.csv(mdf, paste0(mission,"_counts_comparison.csv"), row.names=F,na="")

allmissions=rbind(allmissions,mdf)

}


# tag the methods with data type

greps=c("Chl_a","Chl_Fluor","cond","HPLC","NO2NO3","O2_CTD","O2_El","PAR","Phaeo","PO4","POC","PON","Press",
        "Salinity_CTD", "Salinity_Sal","SiO4","Temp_CTD","NH3","NO2","Secchi","Salinity_CTDloop",
        "Temp_CTD_loop","TOC","ph_CTD","Winkler","Fluoresc","CO2")

tags=c("chl","chl_ctd","cond","hplc","nit","O2_ctd","O2_el","par","phaeo","pho","poc","pon","press",
       "sal_ctd", "sal_sal","sil","temp_ctd","amo","no2","secchi","sal_loop","temp_loop","toc",
       "ph_ctd","winkler","fluo","co2")

allmissions$tag=NA

for (i in 1:length(greps)) {
im=grep(greps[i],allmissions$METHOD)
allmissions$tag[im]=tags[i]
}

write.csv(allmissions, "AZMP_all_counts_comparison_tagged.csv", row.names=F, na="")

