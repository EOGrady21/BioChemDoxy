#find all concecated QAT files

# 
# files <- list.files('R:/Science/BIODataSvc/SRC/2010s/', pattern = '*_QAT.csv', recursive = T)
# 
# #HUD2016006 is empty
# files <- files[-22]
# 
# save.image(file = 'ALL_QAT.RData')
# 
# load('ALL_QAT.RData')


files <- list.files('~/BIOCHEM/DATA/QAT/')

#blanks
#files <- files[-54]

hdr<- list()
for (i in 1:length(files)){
   a<- read.csv( files[i], header = T)
  hdr[i] <- list(names(a))
}

file_name <- list()
cruise_number <- list()
station_number <- list()
latitude<- list()
longitude<- list()
trip_number<- list()
event_number<- list()
sample_ID<- list()
date<- list()
time<- list()
sigma_theta<- list()
oxygen<- list()
theta<- list()
salinity<- list()
scan<- list()
temperature<- list()
pressure<- list()
conductivity<- list()
rosette_postion<- list()
fluorescence<- list()
ph<- list()
par<- list()
altimeter<- list()


for (i in 1:length(hdr)){
a <- grep(hdr[[i]], pattern = 'file', ignore.case = T, value = T)
if (length(a) != 0){
  file_name[i] <- a
}
b <- grep(hdr[[i]], pattern = 'cruise', ignore.case = T, value = T)
if (length(b) != 0){
  cruise_number[i] <- b
}
c <- grep(hdr[[i]], pattern = 'station', ignore.case = T, value = T)
if (length(c) != 0){
  station_number[i] <- c
}

d <- grep(hdr[[i]], pattern = 'lat', ignore.case = T, value = T)
if (length(d) != 0){
  latitude[i] <- d
}
e <- grep(hdr[[i]], pattern = 'lon', ignore.case = T, value = T)
if (length(e) != 0){
  longitude[i] <- e
}

f <- grep(hdr[[i]], pattern = 'trip', ignore.case = T, value = T)
if (length(f) != 0){
  trip_number[i] <- f
}

g <- grep(hdr[[i]], pattern = 'event', ignore.case = T, value = T)
if (length(g) != 0){
  event_number[i] <- g
}

h <- grep(hdr[[i]], pattern = 'sample', ignore.case = T, value = T)
if (length(h) != 0){
  sample_ID[i] <- h
}

j <- grep(hdr[[i]], pattern = 'date', ignore.case = T, value = T)
if (length(j) != 0){
  date[i] <- j
}

k <- grep(hdr[[i]], pattern = 'time', ignore.case = T, value = T)
if (length(k) != 0){
  time[i] <- k
}

l <- grep(hdr[[i]], pattern = 'sigma', ignore.case = T, value = T)
if (length(l) != 0){
  sigma_theta[i] <- l
}

m <- grep(hdr[[i]], pattern = 'oxygen', ignore.case = T, value = T)
if (length(m) != 0){
  oxygen[i] <- m
}

n <- grep(hdr[[i]], pattern = 'theta', ignore.case = T, value = T)
if (length(n) != 0){
  theta[i] <- n
}

o <- grep(hdr[[i]], pattern = 'sal', ignore.case = T, value = T)
if (length(o) != 0){
  salinity[i] <- o
}

p <- grep(hdr[[i]], pattern = 'scan', ignore.case = T, value = T)
if (length(p) != 0){
  scan[i] <- p
}

q <- grep(hdr[[i]], pattern = 'temp', ignore.case = T, value = T)
if (length(q) != 0){
  temperature[i] <- q
}

r <- grep(hdr[[i]], pattern = 'pressure', ignore.case = T, value = T)
if (length(r) != 0){
  pressure[i] <- r
}

s <- grep(hdr[[i]], pattern = 'cond', ignore.case = T, value = T)
if (length(s) != 0){
  conductivity[i] <- s
}

t <- grep(hdr[[i]], pattern = 'ros', ignore.case = T, value = T)
if (length(t) != 0){
  rosette_postion[i] <- t
}

u <- grep(hdr[[i]], pattern = 'flu', ignore.case = T, value = T)
if (length(u) != 0){
  fluorescence[i] <- u
}

v <- grep(hdr[[i]], pattern = 'ph', ignore.case = T, value = T)
if (length(v) != 0){
  ph[i] <- v
}

w <- grep(hdr[[i]], pattern = 'par', ignore.case = T, value = T)
if (length(w) != 0){
  par[i] <- w
}

x <- grep(hdr[[i]], pattern = 'alt', ignore.case = T, value = T)
if (length(x) != 0){
  altimeter[i] <- x
}


remove(a,b,c,d,e,f,g,h,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x)
}

remove(i)


save.image(file = 'HEADER_NAMES.RData')


#####
HDR_NAMES <- list()

HDR_NAMES$sample_ID <- unique(sample_ID)
HDR_NAMES$altimeter <- unique(altimeter)
HDR_NAMES$conductivity <- unique(conductivity)
HDR_NAMES$cruise_number <- unique(cruise_number)
HDR_NAMES$date <- unique(date)
HDR_NAMES$event_number <- unique(event_number)
HDR_NAMES$file_name <- unique(file_name)
HDR_NAMES$fluorescence <- unique(fluorescence)
HDR_NAMES$latitude <- unique(latitude)
HDR_NAMES$longitude <- unique(longitude)
HDR_NAMES$oxygen <- unique(oxygen)
HDR_NAMES$par <- unique(par)
HDR_NAMES$ph <- unique(ph)
HDR_NAMES$pressure <- unique(pressure)
HDR_NAMES$rosette_position <- unique(rosette_postion)
HDR_NAMES$salinity <- unique(salinity)
HDR_NAMES$scan <- unique(scan)
HDR_NAMES$sigma_theta <- unique(sigma_theta)
HDR_NAMES$station_number <- unique(station_number)
HDR_NAMES$temperature <- unique(temperature)
HDR_NAMES$theta <- unique(theta)
HDR_NAMES$time <- unique(time)
HDR_NAMES$trip_number <- unique(trip_number)

#save(HDR_NAMES, file = 'HDR_NAMES.RData')

load("~/BIOCHEM/DATA/QAT/HDR_NAMES.RData")
