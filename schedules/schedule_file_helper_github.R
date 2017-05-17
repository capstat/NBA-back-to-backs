#all schedules was a 50 MB file.  could not upload to github
#broke the file into 3 parts

#all = read.csv("schedules/allNBA_gameresults_1979-2017.csv")
#nrow(all)
#write.csv(all[c(1:30000),], 
#          "schedules/allNBA_gameresults_1979-2017-1.csv", row.names=FALSE)
#write.csv(all[c(30001:60000),], 
#          "schedules/allNBA_gameresults_1979-2017-2.csv", row.names=FALSE)
#write.csv(all[c(60001:nrow(all)),], 
#          "schedules/allNBA_gameresults_1979-2017-3.csv", row.names=FALSE)

#script to put the file back together
x1 = read.csv("schedules/allNBA_gameresults_1979-2017-1.csv")
x2 = read.csv("schedules/allNBA_gameresults_1979-2017-2.csv")
x3 = read.csv("schedules/allNBA_gameresults_1979-2017-3.csv")

write.csv(rbind(x1,x2,x3),
  "schedules/allNBA_gameresults_1979-2017.csv", row.names=FALSE)

