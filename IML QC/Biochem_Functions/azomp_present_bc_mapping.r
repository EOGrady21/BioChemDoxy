# Make AZOMP mapping inventory

source("query_biochem.r")
source("replace_hplc.r")

# load the list of the cruises
cruises=read.csv("AZOMP_cruises.csv",stringsAsFactors=F)

# make a descriptor string for query
desc=paste("'",cruises$descriptor,"'",collapse=", ",sep="")

query=paste0("select distinct METHOD, descriptor from BIOCHEM.DISCRETE_DATA where descriptor in (",desc,");")

mapping=query_biochem(query)

# replace HPLC list with just HPLC
#m=replace_hplc(mapping)

# make a table for mapping
mt=table(mapping)

write.csv(mt,"azomp_bc_present_mapping.csv")
