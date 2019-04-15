# This is a draft of a script that would get data from BCD file and convert it to IML format 
# so it can be run in Matlab IML QC code. For now below are just ideas how to deal with different issues
# The bcd format is long and IML format is wide, plus it has additional clumns for QC flags.
# deal with duplicates
# this is how to change format of the data from long to wide
# duplicates are renamed and placed in a separate column

# test data frame 
d=read.csv("test_4melt.csv")

# the columns are: mission, depth,type (data type), value, and id (sample id)
# one of the data type has duplicates (POC)

# deal with duplicates
# find duplicates for each sample ID
duple=which(duplicated(d[,c("type","id")]))

# rename data type for duplicates so they can be places in separate columns
# in this case add _2 in the end of the datatype
d$type[duple]=paste0(d$type[duple],"_2")

require(reshape)

# now they can be casted to the wide format
# Option 1: include all fields in the formula
wide=cast(d,id+mission+depth~type,paste)


# Option 2: I can just convert BCD to wide format using ID only
# and later merge to required metadata fields from BCS

wide2=cast(d,id~type,paste) # this can be then merged to BCS metadata

# need to add columns for quality flags
adnames=paste0("Q_",names(wide2))
flagnames=adnames[-grep("Q_id",adnames)] # remove a flag for id


wide2[,flagnames]=0 #add columns for flags and set them to zero


# this is for the end to merge flags all in one column
flags$total=apply(flags,1,max, na.rm=T)

# example: flags data frame have columns f1, f2, and f3
# f1 f2 f3 total
# NA  2 NA     2
# NA  2 NA     2
# NA  2 NA     2
# NA  2 NA     2
#  1 NA NA     1
#  1 NA NA     1
#  1 NA NA     1
#  1 NA NA     1
#  1 NA NA     1
#  1 NA NA     1
# NA NA  3     3
# NA NA  3     3
