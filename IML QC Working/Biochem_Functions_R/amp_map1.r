#

install.packages("marmap")
require(marmap)

# get bathymetry data for AZMP region
depth<-getNOAA.bathy(-70, -41, 41, 56)

# define blue color palette
blues <- c("lightsteelblue4", "lightsteelblue3",
           "lightsteelblue2", "lightsteelblue1","lightblue","lightcyan")

# define gray color pallete
greys <- c(grey(0.6), grey(0.93), grey(0.99))


# plot the map
plot(papoue, n=0,image = TRUE, land = TRUE, lwd = 0.03,
     bpal = list(c(0, max(papoue), greys),
                 c(min(papoue), 0, blues)))
