library(dplyr)
library(boot)
library(stringr)
library(ggplot2)

source("spread_scraper.R", local=TRUE)

all_schedules = read.csv(paste0("schedules/allNBA_gameresults_", 
                                min(YEARS-1), "-", max(YEARS), ".csv"),
                         stringsAsFactors=FALSE)
#only train model up to 2014
test = all_schedules[all_schedules$year. >= 2015,]
#only going to keep back to back games on the road
test = test[test$BB.==TRUE & test$H_A.=="Away",]
#only keep games that are played after the 10th game for both teams
#home team might not have played 10 yet
test = test[test$G. > 10 & test$G.Opp > 10 &
              test$G. < 70 & test$G.Opp < 70 &
              !is.na(test$Last10_GB4.Opp),] 

#dont keep games at the beginning or end of the season
ms = c("Nov", "Dec", "Jan", "Feb", "Mar")
test = filter(test, Month. %in% ms)
#find the difference between the win pcts
test$pytWpct_GB4_Diff = test$A_pytWpct_GB4. - test$H_pytWpct_GB4.Opp

load("modelfile")
cor(model.matrix(fit3)[,-1])

#predict the values using the model
test$p = predict(fit3, test)
#perform the logit transformation
test$ExpW_prop = inv.logit(test$p)
#separate data into 5 groups based upon 
test$Cuts_ExpW = as.numeric(
  cut_number(test$ExpW_prop, 5))
#save a copy
write.csv(test, "test.csv", row.names=FALSE)

#get historical money line using the scraper
spreads = spread_scraper(test)

#match the team ids from the spreads to the model
team_sort = sort(unique(test$Team))[c(1:3,5,4,6:30)]
spreads$Away = plyr::mapvalues(spreads$Away, 
                               from=sort(unique(spreads$Away)), 
                               to=team_sort)
spreads$Home = plyr::mapvalues(spreads$Home, 
                               from=sort(unique(spreads$Home)), 
                               to=team_sort)
#help join on date
test$date_helper = str_replace_all(test$Date, "-", "")
test_spreads = left_join(test, spreads, by=c("Team"="Away", 
                                             "date_helper"="Date"))
#only keep some columns
test_spreads = test_spreads[,c("Team","Opp_Abbr","Date","Tm.","Opp.",
                               "Result.","pytWpct_GB4_Diff","ExpW_prop",
                               "Cuts_ExpW","AwayLine","HomeLine")]
#calculate take home for $1000 away games
test_spreads$bet_result_away = ifelse(test_spreads$AwayLine>0,
                                      10*test_spreads$AwayLine,
                                      1000*100/abs(test_spreads$AwayLine))
#calculate for home games
test_spreads$bet_result_home = ifelse(test_spreads$HomeLine>0,
                                      10*test_spreads$HomeLine,
                                      1000*100/abs(test_spreads$HomeLine))

#take a look at the picks the model is most confident in
ts = filter(test_spreads, test_spreads$Cuts_ExpW=="5")
ts$bet_result = -1000
ts$bet_result = ifelse(ts$Result.=="W", ts$bet_result_away, 
                       ts$bet_result)
sum(ts$bet_result)

#use the model to see how often we are correct
temp = fit3$data
temp$Cuts_ExpW = as.numeric(
  cut_number(fit3$fitted.values, 5))
t = prop.table(table(temp$Result.[temp$Cuts_ExpW=="5"]))

#use % correct to find out when we should bet
#p = x/(x+y) -> expected value
y = (1000/t[2])-1000

#only bet expect to win > y
ts$bet_result = ifelse(ts$bet_result_away < y, 
                       0, ts$bet_result)
sum(ts$bet_result[ts$AwayLine>0])
