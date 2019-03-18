# compute ranges for some parameters by avaraging bcd data
# plot histograms for all depths
# determine mean and std.
# determine range as mean + - 3*std


# read BCD file
bcd=read.csv("AZMP_BCD_BC.csv",stringsAsFactors=F)
unique(bcd$DATA_TYPE_METHOD)
 
pars=c("Phaeo_","CO2", "NH3","POC","PON")

pars=unique(bcd$DATA_TYPE_METHOD)
pars=pars[-grep("HPLC",pars)]

# compute climatology for each parameters, all depths and seasons included

for (i in 1:length(pars)) {
  
  ind=grep(pars[i],bcd$DATA_TYPE_METHOD)
  
  df=bcd[ind,]
  p=df$DIS_DETAIL_DATA_VALUE
  
  ll=mean(p)-3*sd(p) # lower limit
  ul=mean(p)+3*sd(p) # upper limit
  
  title=paste0(df$DATA_TYPE_METHOD[1], ", ",dim(df)[1]," records") # title for the plots
  
  boxplot(p, main=title, col="dodgerblue")
  abline(0,0, col="red")
  abline(ll,0, col="green", lty=2)
  abline(ul,0, col="green", lty=2)
  
  plot(p,-df$DIS_HEADER_START_DEPTH, pch=19, col="dodgerblue", main=title, ylab="Depth [m]", xlab="Data value")
  
  hist(p,100,col="dodgerblue", main=title, xlab="Data Value")
 
  
}