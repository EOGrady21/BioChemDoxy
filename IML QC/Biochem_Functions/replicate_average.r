# compute average from replicates samples
# some test lines


# RENAME CHN COLUMNS
#chn_names=c("I.D.","VOLUME(L)","CARBON(micrograms)","NITROGEN(micrograms)","C/L(micrograms/litre)",
#"N/L(micrograms/litre)", "C/N")

#chn_short=c("id","volume","c_um","n_um","poc","pon", "cn_ratio")


# compute avarage value from duplicates
chn_mean=aggregate(.~ I.D., mean, data = chn)

# duplicates will be loaded
# compute standard deviation of duplicates
chn_stdp=aggregate(.~ I.D., function(x){100*sd(x)/mean(x)}, data = chn)

# compute number of points (duplicates or triplicates?)
chn_n=aggregate(.~ I.D., length, data = chn)