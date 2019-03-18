
# replace all HPLC pigments with just HPLC line 
# comes handy when making tables so it is listing one HPLC line insted of 23 HPLC pigments.
# Gordana Lazin, BioCem Reboot, 2016/17


replace_hplc <- function(x) {
  # replace all HPLC pigments with only one line saying HPLC
  hplc=grep("HPLC_",x$METHOD)
  hp1=hplc[1]
  hp_extra=hplc[2:length(hplc)]
  
  # rename all hplc rows with HPLC
  x$METHOD[hplc]="HPLC"
  
  # remove all HPLC rows but one
  x=x[-hp_extra,]
  return (x)
}
