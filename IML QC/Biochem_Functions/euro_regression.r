# plot euro/cad change

change_in_exchange_rate=seq(0.01,0.1,0.01)

change_in_cad=22500*change_in_exchange_rate

plot(change_in_exchange_rate,change_in_cad,type="b", xaxt = "n",yaxt = "n", main="For 22.5 K euro")
atx=change_in_exchange_rate
aty=seq(100,2500,200)

axis(side = 1, at = atx)
axis(side = 2, at = aty)
abline(h=aty, v=atx, col="gray", lty=3)
