library(dplyr)

all_schedules = read.csv(paste0("schedules/allNBA_gameresults_", 
                                min(YEARS-1), "-", max(YEARS), ".csv"),
                         stringsAsFactors=FALSE)

#add team age
team_info = read.csv("nba_team_info.csv", stringsAsFactors=FALSE)
colnames(team_info)[1] = c("Team")
#season ex 2013-2014
team_info$Season = paste(team_info$year-1, team_info$year, sep="-")
all_schedules = left_join(all_schedules, team_info, by=c("Team","Season"))

#some variables represent data that happened 
#after the game or we need from the game before
#if the game before went into overtime
all_schedules = all_schedules %>% group_by(link) %>%
  mutate(Result_GB4=lag(Result),
         OT_GB4=lag(OT),
         Point_Diff_GB4=lag(Point_Diff),
         Last10_GB4=lag(Last10))
#all points and win% inc the game
all_schedules = all_schedules %>% group_by(link, H_A) %>%
  mutate(A_pytWpct_GB4=lag(A_pytWpct),
         H_pytWpct_GB4=lag(H_pytWpct))

#add opponent info
all_schedules = left_join(all_schedules, all_schedules, 
                          by=c("Date","Opp_Abbr"="Team"),
                          suffix=c(".",".Opp"))

write.csv(all_schedules, 
          paste0("schedules/allNBA_gameresults_", 
                 min(YEARS-1), "-", max(YEARS), ".csv"),
          row.names=FALSE)
