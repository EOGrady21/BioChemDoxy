# Make BioChem Gantt chart

library("plan")

bc <- read.gantt("biochem_gantt_plan.csv")

plot(bc)