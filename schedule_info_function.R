library(stringr)
library(lubridate)
library(Hmisc)

#@param s -> team schedule
#function to add information to the team schedules
#returns the schedule with new info added
schedule_info_function = function(s){
  #change to numeric
  s$G = as.numeric(s$G)
  s$Tm = as.numeric(s$Tm) 
  s$Opp = as.numeric(s$Opp)
  #rename some columns
  colnames(s)[c(5,7,8)] = c("H_A", "Result", "OT")
  #day of the week and month
  s$Day = str_sub(s$Date, 1, 2)
  s$Month = str_sub(s$Date, 6, 8)
  #reformat the date
  s$Date = mdy(str_sub(s$Date, 6))
  #change @ to home or away
  s$H_A = ifelse(s$H_A == "@", "Away", "Home")
  #change OT to T/F
  s$OT = ifelse(s$OT == "OT", TRUE, FALSE)
  #some of the OTs were NA -> change them to FALSE
  s$OT = ifelse(is.na(s$OT), FALSE, s$OT)
  #days between games
  s$Days_Off = as.numeric(difftime(s$Date, Lag(s$Date)))-1
  #T/F for back to backs
  s$BB = ifelse(s$Days_Off == 0, TRUE, FALSE)
  #BB type
  s$BB_Type = ifelse(s$BB==TRUE, paste0(Lag(s$H_A), s$H_A), NA)
  #point diff from previous game
  s$Point_Diff = s$Tm - s$Opp
  #road trip info
  trip_helper = ifelse(s$H_A=="Away",1,0)
  #from stack overflow
  #R cumsum by condition with reset
  s$Cons_Games_Home_Away = ave(trip_helper,
                               cumsum(c(F, diff(trip_helper) != 0)), 
                               FUN=seq_along)
  #rolling home win %
  s$HW = cumsum(s$Result == "W" & s$H_A == "Home")
  s$HL = cumsum(s$Result == "L" & s$H_A == "Home")
  s$HWpct = s$HW/(s$HW+s$HL)
  #rolling away win %
  s$AW = cumsum(s$Result == "W" & s$H_A == "Away")
  s$AL = cumsum(s$Result == "L" & s$H_A == "Away")
  s$AWpct = s$AW/(s$AW+s$AL)
  #rolling home pyt win %
  s$H_Points_For[s$H_A == "Home"] = cumsum(s$Tm[s$H_A == "Home"])
  s$H_Points_Against[s$H_A == "Home"] = cumsum(s$Opp[s$H_A == "Home"])
  s$H_pytWpct = s$H_Points_For^13.91/
    (s$H_Points_For^13.91+s$H_Points_Against^13.91)
  #rolling away pyt win %
  s$A_Points_For[s$H_A == "Away"] = cumsum(s$Tm[s$H_A == "Away"])
  s$A_Points_Against[s$H_A == "Away"] = cumsum(s$Opp[s$H_A == "Away"])
  s$A_pytWpct = s$A_Points_For^13.91/
    (s$A_Points_For^13.91+s$A_Points_Against^13.91)
  #last 10 games
  s$Last10 = NA
  #length of home stand or road trip
  s$Trip_Stand_Length_Games = 1
  s$Days_On_Road = NA
  day_helper = TRUE
  for(i in 1:nrow(s)){
    #length of home stand or road trip
    if(s$Cons_Games_Home_Away[i] > 1){
      temp = s$Cons_Games_Home_Away[i]
      s$Trip_Stand_Length_Games[i:(i-temp+1)] = temp
    }
    #trip length in days
    if(s$H_A[i] == "Away" & day_helper == TRUE){
      #day trip starts
      start = s$Date[i]
      #length is 1 for a one day road trip
      s$Days_On_Road[i] = 1
      day_helper = FALSE
    } else if(s$H_A[i] == "Away" & day_helper == FALSE){
      #find the difference in the days
      s$Days_On_Road[i] = as.numeric(difftime(s$Date[i], start))+1
    } else{
      #reset the day helper
      day_helper = TRUE
    }
    #for last 10 games 
    if(s$G[i]>=10){
      #last 10 game winning %
      s$Last10[i] = sum(s$Result[(i-9):i] == "W")/10
    }
  }
  #how many games left on home stand
  s$Games_Left_Trip_Stand = s$Trip_Stand_Length_Games-s$Cons_Games_Home_Away
  return(s)
} 
