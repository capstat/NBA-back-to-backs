library(dplyr)

all_schedules = read.csv(paste0("schedules/allNBA_gameresults_", 
                                min(YEARS-1), "-", max(YEARS), ".csv"),
                         stringsAsFactors=FALSE)
#only train model up to 2014
train = all_schedules[all_schedules$year. < 2015,]
#only going to keep back to back games on the road
the_model = train[train$BB.==TRUE & 
                    train$H_A.=="Away",]
#only keep games that are played after the 10th game for both teams
#home team might not have played 10 yet
the_model = the_model[the_model$G. > 10 & the_model$G.Opp > 10 &
                        the_model$G. < 70 & the_model$G.Opp < 70 &
                        !is.na(the_model$Last10_GB4.Opp),] 

#dont keep games at the beginning or end of the season
ms = c("Nov", "Dec", "Jan", "Feb", "Mar")
the_model = filter(the_model, Month. %in% ms)
#find the difference between the win pcts
the_model$pytWpct_GB4_Diff = the_model$A_pytWpct_GB4. - the_model$H_pytWpct_GB4.Opp
#change categorical variables to factors
the_model[,c(2:5,13,14,19,23,24,41)] = lapply(the_model[,c(2:5,13,14,19,23,24,41)], factor)

#save the model
write.csv(the_model, "the_model.csv", row.names=FALSE)
