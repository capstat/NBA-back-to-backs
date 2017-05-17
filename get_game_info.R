library(rvest)
source("schedule_info_function.R", local=TRUE)

#all stats come from basketball-reference.com
NBA = "http://www.basketball-reference.com/teams/%s/%s_games.html"
teams_df = read.csv("NBA_team_info.csv")

#scrape schedules for every team since the introduction of the 3 pointer
#create a csv file for every team to save info
all_teams = unique(teams_df$abbr)
#initaliize an empty data frame to store all games
all_schedules = data.frame()

for(each in all_teams){
  #initialize an empty data frame
  schedule = data.frame()
  #extract the years that the team existed
  years = unique(teams_df$year[teams_df$abbr == each])
  #scrape schedule of each year
  for(year in years){
    #html page for team schedule
    temp_html = read_html(sprintf(NBA, each, year)) 
    temp_sched = temp_html %>%  
      html_node('table') %>%
      html_table() 
    #add team abbr and season to df
    temp_sched$Team = each
    temp_sched$Season = paste0(year-1, "-", year)
    #remove header rows and keep columns that we will use
    temp_sched = temp_sched[str_detect(temp_sched$G, "\\d"), 
                            c(16,17,1,2,6:8,9:14)]
    #scrape links to opponents
    opp_links = html_nodes(temp_html, "#games td a") %>% 
      html_attr("href")
    temp_sched$Opp_link = opp_links[str_detect(opp_links, "teams")]
    #function to add info to the team schedule
    temp_sched = schedule_info_function(temp_sched)
    #combine all schedules of one team together
    schedule = rbind(schedule, temp_sched)
    print(paste(each, year))
  }
  #add team schedule to master schedule file
  all_schedules = rbind(all_schedules, schedule)
  #save team schedule
  write.csv(schedule, 
            paste0("schedules/", each, "_gameresults_", 
                   min(years-1), "-", max(years), ".csv"),
            row.names=FALSE)
}
write.csv(all_schedules, 
          paste0("schedules/allNBA_gameresults_", 
                 min(YEARS-1), "-", max(YEARS), ".csv"),
          row.names=FALSE)
