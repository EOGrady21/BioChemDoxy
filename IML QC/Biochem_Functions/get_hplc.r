# Read HPLC data file and stack it for BioChem reload
# This function is used for azmp_bcd1.r main script

# Gordana Lazin, June 20, 2016

get_hplc <- function(mission,hplcFile) {

  
# read excel file - make sure they are all in the he same format
hplc=read_excel(hplcFile,sheet="Pigments",skip=2)

# convert to regular data frame
hplc=as.data.frame(hplc)

# remove NA rows from the dataframe
if (length(na.rows(hplc))>0) {
  hplc=hplc[-na.rows(hplc),]
}

hplc0=hplc

# remove "TOTCHLC" as this is not loaded to BioChem
totc=which(names(hplc)=="TOTCHLC")

if (length(totc)>0) {
  hplc=hplc[,-totc]
}

# to accomodate Matt's files, rename HPLCHLA to HPLCCHLA, to match Heidi's original naming
names(hplc)=gsub("HPLCHLA","HPLCCHLA",names(hplc))

# rename columns to BioChem names

# biochem has 23 METHOD for hplc data
bc_hplc=c("HPLC_ACAROT","HPLC_ALLOX","HPLC_ASTAX","HPLC_BCAROT","HPLC_BUT19","HPLC_BUTLIKE","HPLC_CHLA",
          "HPLC_CHLB","HPLC_CHLC12","HPLC_CHLC3","HPLC_CHLIDEA","HPLC_DIADINOX","HPLC_DIATOX","HPLC_FUCOX",
          "HPLC_HEX19","HPLC_HEXLIKE","HPLC_HEXLIKE2","HPLC_PERID","HPLC_PHAEO","HPLC_PRASINOX","HPLC_PYROPHAE",
          "HPLC_VIOLAX","HPLC_ZEA")

# remove "HPLC_" from biochem pigment names so you can match it with excel names. 
# pigment names without hplc_ in front
bch=gsub("HPLC_","",bc_hplc) # methods from biochem
fch=gsub("HPLC","",names(hplc),ignore.case=TRUE) # column names from data

# sometimes original files have PHAE incted of PHAEO, so that has to be replaced
if (length(which(fch=="PHAE"))>0) {
  fch[which(fch=="PHAE")]="PHAEO"
}

# match pigment names in hplc file to the names from biochem

# find corresponding columns
ni=match(fch,bch)

# rename hplc clumns with names for BioChem
mn=which(!is.na(ni)) # matching names


#hplc=hplc0 # just temporary line for testing

# replace names in hplc file with the biochem METHOD
names(hplc)[mn]=bc_hplc[ni[mn]]

# are all columns in hplc file matched?
nomatch=setdiff(names(hplc),names(hplc)[mn]) # difference between all names in HPLC file and matching names
not_pigments=c("ID","DEPTH")

# difference between pigments in HPLC file and the ones in BioChem
sd=setdiff(nomatch,not_pigments)

# biochem stores 23 pigments
cat("\n","\n")
cat(paste("-> HPLC data: HPLC file for", mission, "contains", length(mn), "pigments. BioChem stores 23 HPLC pigments."))
cat("\n","\n")

if (length(sd)==0) {
  cat("\n","\n")
  cat(paste("-> HPLC data: All",length(mn), "pigments in HPLC file matched to BioChem METHOD."))
  
}

if (length(sd)>0) {
  
  cat("-> HPLC data: Pigments NOT matched to the HPLC methods in BioChem:",paste(sd,collapse=", "))
  cat("\n","\n")
  cat("-> HPLC data: You can continue without those fields or you can correct pigment spelling in the HPLC file.")
  cat("\n","\n")
  op=readline("Would you like to continue withot those fields (y or n)?:")
  
  
  if (op=="y") {
    hplc=hplc[,-which(names(hplc) %in% sd)]
    cat("\n","\n")
    cat(paste("-> HPLC data: Fields removed from HPLC data:",paste(sd,collapse=", ")))
  }
  
  if (op=="n") {
    cat("\n","\n")
    cat("-> HPLC data: Please correct pigment spelling in the HPLC excel sheet.")
    cat("\n","\n")
    cat("-> HPLC data: Pigments type in BioChem are following:")
    cat("\n","\n")
    print(bc_hplc)
    stop()
  }
  
}


# remove DEPTH column
dpth=grep("DEPTH",names(hplc))

if (length(dpth)>0){
  hplc=hplc[,-dpth] 
}

# rename ID to id
names(hplc)[which(names(hplc)=="ID")]="id"

# returns HLC file with ID and all pigments matched to the BioChem METHOD

# for the cruise HUD2009048 convert id to numeric
if (mission=="HUD2009048") {
  hplc$id=as.numeric(hplc$id)
}

return(hplc)

}
