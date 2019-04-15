# flag color

flagcol2 <- function(x) {
  
  fcol=rep("n",length(x))
  

  fcol[which(x==2)]="yellow"
  fcol[which(x==3)]="orange"
  fcol[which(x==4)]="red"
  fcol[which(x==7)]="springgreen"


  
  return(fcol)
  
}