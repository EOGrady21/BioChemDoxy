# this is the test that I did for matching 
# to figure out how match works

# test matching flags
a=c(221,222,223,224,225,226,227)
a=data.frame(cbind(a,c(0,0,0,0,0,0,0)))

b=c(221,223,224)
b=data.frame(cbind(b,c(1,2,3)))

# one way to replace the flags
a$V2[!is.na(match(a$a,b$b))]=b$V2


# another way, flipped match
a$V2[match(b$b,a$a)]=b$V2


