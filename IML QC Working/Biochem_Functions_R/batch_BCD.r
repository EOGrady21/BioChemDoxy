# Lines to run to enable batch processing for BioChem Reload
# Gordana Lazin, 2016 and 2017

# all AZMP cruises



cruises=c("HUD99054","HUD99003","HUD2000050","HUD2001061","HUD2002064","HUD2003067","HUD2003078","HUD2004055",
          "HUD2005055", "HUD2006052","HUD2007045", "HUD2008037","HUD2009048", "HUD2010049","HUD2011043",
          "HUD2012042", "PAR2000002","HUD2001009","HUD2003005","HUD2004009","NED2005004",
          "HUD2006008","HUD2007001","HUD2008004","HUD2009005","HUD2010006","HUD2011004")

 mission="HUD99003"

for (i in 1:length(cruises)) {
   mission=cruises[i]
   source("bcs_azmp1.r")
   source("bcd_azmp1.r")
   source("write_biochem_table_RODBC.r")
  
   }


 # Create IML format that is input for Matlab QC script using BCD data. 
 # This script runs all cruises in batch.
 # It extracts unique cruise mission IDs from the BCD staging table 
 # and creates IML format files for all of the cruises in the staging table.
 source("BCD2IML_format.r")
 # 
 
 # THIS STEP HAS TO BE DONE IN MATLAB: flag the data in matlab using IML script
 
 # Transfer flags from IML flagged file back to BCD, includes loop for all cruises
 source("get_flags_IML2BCD.r")
 
 
 # Plot only flagged profiles
 # To plot all the cruises one needs to do a loop
 
 mission="HUD2006052"
 
 options(warn=1) # display warnings as they happen
 
 missions_processed=NULL
 
 for (i in 1:length(cruises)) {
   mission=cruises[i]
 
 # Plot flagged profiles, one cruise at the time
 source("plot_flagged_profiles2.r")
   
missions_processed=c(missions_processed,mission) 

   
 }
 
 






# get extra samples files 

extra_samples=NULL

for (i in 1:length(cruises)) {
  mission=cruises[i]
 # file name for extra samples
  fn=file.path(getwd(),mission,paste0(mission,"_extra_samples.csv"))
  
  if (file.exists(fn)) {
    es=read.csv(fn)
    extra_samples=rbind(extra_samples,es)
  }
  
}

# extract BioChem records for those samples

ids=unique(extra_samples$id)

bc=biochem_metadata_sampleID(ids)

# replace all HPLC pigments with just HPLC
bc$METHOD[grep("HPLC",bc$METHOD)]="HPLC"

bc1=unique(bc) # this indicates only 1 record for HPLC

# export extra samples as csv
write.csv(bc1,"Extra_samples_AZMP.csv")

# merge extra samples with biochem output. Maybe some of extra_samples are not in Biochem

not_in_bc=setdiff(unique(extra_samples$id),unique(bc1$COLLECTOR_SAMPLE_ID))

