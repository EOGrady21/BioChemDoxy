# summary of AZMP data

# load BCD table

# bcd_bc contains data from all the missions
bcd=read.csv("AZMP_BCD_BC.csv",stringsAsFactors=F)
bcs=read.csv("AZMP_BCS_BC.csv",stringsAsFactors=F)

# make a table that links mission name with mission descriptor
name_descriptor=unique(data.frame(cbind(bcs$MISSION_NAME, bcs$MISSION_DESCRIPTOR)))
names(name_descriptor)=c("MISSION_NAME","MISSION_DESCRIPTOR")

bcdd=bcd[, c( "MISSION_DESCRIPTOR", "DIS_DETAIL_COLLECTOR_SAMP_ID", "DIS_DETAIL_DATA_VALUE","DATA_TYPE_METHOD")]
bcdd=merge(bcdd,name_descriptor,by="MISSION_DESCRIPTOR", all.x=T)

# aggregate
#sumtab=xtabs(~DATA_TYPE_METHOD+MISSION_DESCRIPTOR, bcdd)

sumtab=table(bcdd$DATA_TYPE_METHOD, bcdd$MISSION_NAME)


# replace all HPLC pigments with only one line saying HPLC
hplc=grep("HPLC_",row.names(sumtab))
hp1=hplc[1]
hp_extra=hplc[2:length(hplc)]

# rename all hplc rows with HPLC
row.names(sumtab)[hplc]="HPLC"

# remove all HPLC rows but one
sumtab=sumtab[-hp_extra,]


# ==== ORDER THE TABLE: ROWS AND COLUMNS =====

# 1. order rows:  import a file with the order of data types
ord=read.csv("data_type_order.csv", stringsAsFactors = F)

# match order of the rows with the desired order
ord2=match(ord$METHOD,row.names(sumtab))

# table with desired order of rows, all cruises
sumtab2=sumtab[ord2,]

# replace 99054 and 99003 with HUD99054 and HUD99003
colnames(sumtab2)=gsub("99054","HUD99054",colnames(sumtab2))
colnames(sumtab2)=gsub("99003","HUD99003",colnames(sumtab2))

# 2. order the columns: make two tables for spring and fall
# read the file with the order
cro=read.csv("cruises_names_season.csv", stringsAsFactors = F)

fallc=cro$cruise[which(cro$season=="fall")] # fall cruises
springc=cro$cruise[which(cro$season=="spring")] # spring cruises

# match sumtab2 columns with the desired order
sumtab_fall=sumtab2[ ,match(fallc,colnames(sumtab2))] # fall table
sumtab_spring=sumtab2[ ,match(springc,colnames(sumtab2))] # spring table


# write out all the tables
write.csv(sumtab2,"AZMP_summary_data.csv") # contains all cruises
write.csv(sumtab_fall,"AZMP_summary_data_fall.csv") #contains fall cruises in order
write.csv(sumtab_spring,"AZMP_summary_data_spring.csv") #contains spring cruises in order

